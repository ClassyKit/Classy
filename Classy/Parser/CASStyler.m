//
//  CASStyler.m
//  Classy
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASStyler.h"
#import "CASParser.h"
#import "CASPropertyDescriptor.h"
#import "UIView+CASAdditions.h"
#import "UITextField+CASAdditions.h"
#import "CASUtilities.h"
#import "CASStyleNode.h"
#import "NSString+CASAdditions.h"

@interface CASStyler ()

@property (nonatomic, strong) NSMutableArray *styleNodes;
@property (nonatomic, strong) NSMapTable *viewClassDescriptorCache;

@end

@implementation CASStyler

+ (instancetype)defaultStyler {
    static CASStyler * _defaultStyler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultStyler = CASStyler.new;
    });
    
    return _defaultStyler;
}

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.viewClassDescriptorCache = NSMapTable.strongToStrongObjectsMapTable;
    [self setupViewClassDescriptors];

    return self;
}

- (void)styleItem:(id<CASStyleableItem>)item {
    if (!self.filePath) {
        // load default style file
        self.filePath = [[NSBundle mainBundle] pathForResource:@"stylesheet.cas" ofType:nil];
    }
    // TODO style lookup table to improve speed.

    for (CASStyleNode *styleNode in self.styleNodes.reverseObjectEnumerator) {
        if ([styleNode.styleSelector shouldSelectItem:item]) {
            // apply style nodes
            for (CASStyleProperty *styleProperty in styleNode.properties) {
                [styleProperty.invocation invokeWithTarget:item];
            }
        }
    }

    item.cas_styleApplied = YES;
}

- (void)setFilePath:(NSString *)filePath {
    NSError *error = nil;
    [self setFilePath:filePath error:&error];
    if (error) {
        CASLog(@"Error: %@", error);
    }
}

- (void)setFilePath:(NSString *)filePath error:(NSError **)error {
    if ([_filePath isEqualToString:filePath]) return;
    _filePath = filePath;

    self.styleNodes = [[CASParser stylesFromFilePath:filePath error:error] mutableCopy];
    if (!self.styleNodes.count) {
        return;
    }

    // order descending by precedence
    [self.styleNodes sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(CASStyleNode *n1, CASStyleNode *n2) {
        if (n1.styleSelector.precedence == n2.styleSelector.precedence) return NSOrderedSame;
        if (n1.styleSelector.precedence <  n2.styleSelector.precedence) return NSOrderedDescending;
        return NSOrderedAscending;
    }];

    // precompute values
    for (CASStyleNode *styleNode in self.styleNodes.reverseObjectEnumerator) {
        for (CASStyleProperty *styleProperty in styleNode.properties) {
            // TODO type checking and throw errors

            // ensure we dont do same node twice
            if (styleProperty.invocation) continue;
            NSInvocation *invocation = [self invocationForClass:styleNode.styleSelector.viewClass styleProperty:styleProperty];
            styleProperty.invocation = invocation;
        }
    }
}

#pragma mark - private

- (NSInvocation *)invocationForClass:(Class)class styleProperty:(CASStyleProperty *)styleProperty {
    CASViewClassDescriptor *viewClassDescriptor = [self viewClassDescriptorForClass:class];
    CASPropertyDescriptor *propertyDescriptor = [viewClassDescriptor propertyDescriptorForKey:styleProperty.name];

    NSInvocation *invocation = [viewClassDescriptor invocationForPropertyDescriptor:propertyDescriptor];
    [invocation retainArguments];
    [propertyDescriptor.argumentDescriptors enumerateObjectsUsingBlock:^(CASArgumentDescriptor *argDescriptor, NSUInteger idx, BOOL *stop) {
        NSInteger argIndex = 2 + idx;

        if (idx > 0) {
            //arguments after first only supports enums at moment
            NSString *valueName = [styleProperty.arguments[argDescriptor.name] cas_stringByCamelCasing];
            if (valueName.length) {
                NSInteger value = [argDescriptor.valuesByName[valueName] integerValue];
                [invocation setArgument:&value atIndex:argIndex];
            }
            return;
        }

        switch (argDescriptor.primitiveType) {
            case CASPrimitiveTypeBOOL: {
                BOOL value = [[styleProperty valueOfTokenType:CASTokenTypeBoolean] boolValue];
                [invocation setArgument:&value atIndex:argIndex];
                break;
            }
            case CASPrimitiveTypeInteger: {
                NSInteger value;
                if (argDescriptor.valuesByName) {
                    NSString *valueName = [[styleProperty valueOfTokenType:CASTokenTypeRef] cas_stringByCamelCasing];
                    value = [argDescriptor.valuesByName[valueName] integerValue];
                } else {
                    value = [[styleProperty valueOfTokenType:CASTokenTypeUnit] integerValue];
                }
                [invocation setArgument:&value atIndex:argIndex];
                break;
            }
            case CASPrimitiveTypeDouble: {
                CGFloat value = [[styleProperty valueOfTokenType:CASTokenTypeUnit] doubleValue];
                [invocation setArgument:&value atIndex:argIndex];
                break;
            }
            case CASPrimitiveTypeCGSize: {
                CGSize size;
                [styleProperty transformValuesToCGSize:&size];
                [invocation setArgument:&size atIndex:argIndex];
                break;
            }
            case CASPrimitiveTypeUIEdgeInsets: {
                UIEdgeInsets insets;
                [styleProperty transformValuesToUIEdgeInsets:&insets];
                [invocation setArgument:&insets atIndex:argIndex];
                break;
            }
            case CASPrimitiveTypeUIOffset : {
                UIOffset offset;
                [styleProperty transformValuesToUIOffset:&offset];
                [invocation setArgument:&offset atIndex:argIndex];
                break;
            }
            default:
                break;
        }

        if (argDescriptor.argumentClass == UIImage.class) {
            UIImage *image = nil;
            [styleProperty transformValuesToUIImage:&image];
            [invocation setArgument:&image atIndex:argIndex];
        } else if (argDescriptor.argumentClass == UIColor.class) {
            UIColor *color = nil;
            [styleProperty transformValuesToUIColor:&color];
            [invocation setArgument:&color atIndex:argIndex];
        } else if (argDescriptor.argumentClass == NSString.class) {
            NSString *string = nil;
            [styleProperty transformValuesToNSString:&string];
            [invocation setArgument:&string atIndex:argIndex];
        }
    }];
    return invocation;
}

- (void)setupViewClassDescriptors {
    // UIView
    CASViewClassDescriptor *viewClassDescriptor = [self viewClassDescriptorForClass:UIView.class];
    viewClassDescriptor.propertyKeyAliases = @{
        @"borderColor"   : @cas_propertykey(UIView, cas_borderColor),
        @"borderWidth"   : @cas_propertykey(UIView, cas_borderWidth),
        @"borderRadius"  : @cas_propertykey(UIView, cas_cornerRadius),
        @"shadowColor"   : @cas_propertykey(UIView, cas_shadowColor),
        @"shadowOffset"  : @cas_propertykey(UIView, cas_shadowOffset),
        @"shadowOpacity" : @cas_propertykey(UIView, cas_shadowOpacity),
        @"shadowRadius"  : @cas_propertykey(UIView, cas_shadowRadius),
    };

    NSDictionary *contentModeMap = @{
        @"fill"        : @(UIViewContentModeScaleToFill),
        @"aspectFit"   : @(UIViewContentModeScaleAspectFit),
        @"aspectFill"  : @(UIViewContentModeScaleAspectFill),
        @"redraw"      : @(UIViewContentModeRedraw),
        @"center"      : @(UIViewContentModeCenter),
        @"top"         : @(UIViewContentModeTop),
        @"bottom"      : @(UIViewContentModeBottom),
        @"left"        : @(UIViewContentModeLeft),
        @"right"       : @(UIViewContentModeRight),
        @"topLeft"     : @(UIViewContentModeTopLeft),
        @"topRight"    : @(UIViewContentModeTopRight),
        @"bottomLeft"  : @(UIViewContentModeBottomLeft),
        @"bottomRight" : @(UIViewContentModeBottomRight),
    };
    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithValuesByName:contentModeMap]] forPropertyKey:@cas_propertykey(UIView, contentMode)];

    // some properties don't show up via reflection so we need to add them manually
    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithClass:UIColor.class]] forPropertyKey:@cas_propertykey(UIView, backgroundColor)];

    // UITextField
    // TODO text insets
    // TODO border insets
    viewClassDescriptor = [self viewClassDescriptorForClass:UITextField.class];
    viewClassDescriptor.propertyKeyAliases = @{
        @"fontColor"           : @cas_propertykey(UITextField, textColor),
        @"fontName"            : @cas_propertykey(UITextField, cas_fontName),
        @"fontSize"            : @cas_propertykey(UITextField, cas_fontSize),
        @"horizontalAlignment" : @cas_propertykey(UITextField, textAlignment),
        @"backgroundImage"     : @cas_propertykey(UITextField, background),
        @"textInsets"          : @cas_propertykey(UITextField, cas_textEdgeInsets),
    };

    NSDictionary *textAlignmentMap = @{
        @"center"    : @(NSTextAlignmentCenter),
        @"left"      : @(NSTextAlignmentLeft),
        @"right"     : @(NSTextAlignmentRight),
        @"justified" : @(NSTextAlignmentJustified),
        @"natural"   : @(NSTextAlignmentNatural),
    };
    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithValuesByName:textAlignmentMap]] forPropertyKey:@cas_propertykey(UITextField, textAlignment)];

    NSDictionary *borderStyleMap = @{
        @"none"    : @(UITextBorderStyleNone),
        @"line"    : @(UITextBorderStyleLine),
        @"bezel"   : @(UITextBorderStyleBezel),
        @"rounded" : @(UITextBorderStyleRoundedRect),
    };
    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithValuesByName:borderStyleMap]] forPropertyKey:@cas_propertykey(UITextField, borderStyle)];

    
    // UIControl
    viewClassDescriptor = [self viewClassDescriptorForClass:UIControl.class];

    NSDictionary *contentVerticalAlignmentMap = @{
        @"center" : @(UIControlContentVerticalAlignmentCenter),
        @"top"    : @(UIControlContentVerticalAlignmentTop),
        @"bottom" : @(UIControlContentVerticalAlignmentBottom),
        @"fill"   : @(UIControlContentVerticalAlignmentFill),
    };
    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithValuesByName:contentVerticalAlignmentMap]] forPropertyKey:@cas_propertykey(UIControl, contentVerticalAlignment)];

    NSDictionary *contentHorizontalAlignmentMap = @{
        @"center" : @(UIControlContentHorizontalAlignmentCenter),
        @"left"   : @(UIControlContentHorizontalAlignmentLeft),
        @"right"  : @(UIControlContentHorizontalAlignmentRight),
        @"fill"   : @(UIControlContentHorizontalAlignmentFill),
    };
    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithValuesByName:contentHorizontalAlignmentMap]] forPropertyKey:@cas_propertykey(UIControl, contentHorizontalAlignment)];

    NSDictionary *controlStateMap = @{
        @"normal"       : @(UIControlStateNormal),
        @"highlighted"  : @(UIControlStateHighlighted),
        @"disabled"     : @(UIControlStateDisabled),
        @"selected"     : @(UIControlStateSelected),
    };

    NSDictionary *barMetricsMap = @{
        @"default"                : @(UIBarMetricsDefault),
        @"landscapePhone"        : @(UIBarMetricsLandscapePhone),
        @"defaultPrompt"         : @(UIBarMetricsDefaultPrompt),
        @"landscapePhonePrompt" : @(UIBarMetricsLandscapePhonePrompt),
    };

    // UIButton
    viewClassDescriptor = [self viewClassDescriptorForClass:UIButton.class];

    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithClass:UIColor.class], [CASArgumentDescriptor argWithName:@"state" valuesByName:controlStateMap]] setter:@selector(setTitleColor:forState:) forPropertyKey:@"titleColor"];

    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithClass:UIColor.class], [CASArgumentDescriptor argWithName:@"state" valuesByName:controlStateMap]] setter:@selector(setTitleShadowColor:forState:) forPropertyKey:@"titleShadowColor"];

    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithClass:UIImage.class], [CASArgumentDescriptor argWithName:@"state" valuesByName:controlStateMap]] setter:@selector(setBackgroundImage:forState:) forPropertyKey:@"backgroundImage"];

    // UIBarButtonItem
    viewClassDescriptor = [self viewClassDescriptorForClass:UIBarButtonItem.class];

    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithClass:UIImage.class], [CASArgumentDescriptor argWithName:@"state" valuesByName:controlStateMap], [CASArgumentDescriptor argWithName:@"barMetrics" valuesByName:barMetricsMap]] setter:@selector(setBackgroundImage:forState:barMetrics:) forPropertyKey:@"backgroundImage"];

    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithObjCType:@encode(CGFloat)], [CASArgumentDescriptor argWithName:@"barMetrics" valuesByName:barMetricsMap]] setter:@selector(setBackgroundVerticalPositionAdjustment:forBarMetrics:) forPropertyKey:@"backgroundVerticalPositionAdjustment"];

    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithObjCType:@encode(UIOffset)], [CASArgumentDescriptor argWithName:@"barMetrics" valuesByName:barMetricsMap]] setter:@selector(setTitlePositionAdjustment:forBarMetrics:) forPropertyKey:@"titlePositionAdjustment"];

    //backButton
    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithClass:UIImage.class], [CASArgumentDescriptor argWithName:@"state" valuesByName:controlStateMap], [CASArgumentDescriptor argWithName:@"barMetrics" valuesByName:barMetricsMap]] setter:@selector(setBackButtonBackgroundImage:forState:barMetrics:) forPropertyKey:@"backButtonBackgroundImage"];

    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithObjCType:@encode(CGFloat)], [CASArgumentDescriptor argWithName:@"barMetrics" valuesByName:barMetricsMap]] setter:@selector(setBackButtonBackgroundVerticalPositionAdjustment:forBarMetrics:) forPropertyKey:@"backButtonBackgroundVerticalPositionAdjustment"];

    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithObjCType:@encode(UIOffset)], [CASArgumentDescriptor argWithName:@"barMetrics" valuesByName:barMetricsMap]] setter:@selector(setBackButtonTitlePositionAdjustment:forBarMetrics:) forPropertyKey:@"backButtonTitlePositionAdjustment"];

    // UINavigationBar
    viewClassDescriptor = [self viewClassDescriptorForClass:UINavigationBar.class];
    NSDictionary *barPositionMap;
    if (CASKeyDeviceSystemMajorVersion() >= 7) {
        barPositionMap = @{
            @"any"          : @(UIBarPositionAny),
            @"bottom"       : @(UIBarPositionBottom),
            @"top"          : @(UIBarPositionTop),
            @"topAttached"  : @(UIBarPositionTopAttached),
        };
        [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithClass:UIImage.class], [CASArgumentDescriptor argWithName:@"barPosition" valuesByName:barPositionMap], [CASArgumentDescriptor argWithName:@"barMetrics" valuesByName:barMetricsMap]] setter:@selector(setBackgroundImage:forBarPosition:barMetrics:) forPropertyKey:@"backgroundImage"];
    } else {
        [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithClass:UIImage.class], [CASArgumentDescriptor argWithName:@"barMetrics" valuesByName:barMetricsMap]] setter:@selector(setBackgroundImage:forBarMetrics:) forPropertyKey:@"backgroundImage"];
    }

    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithObjCType:@encode(CGFloat)], [CASArgumentDescriptor argWithName:@"barMetrics" valuesByName:barMetricsMap]] setter:@selector(setTitleVerticalPositionAdjustment:forBarMetrics:) forPropertyKey:@"titleVerticalPositionAdjustment"];

    // UISearchBar
    viewClassDescriptor = [self viewClassDescriptorForClass:UISearchBar.class];
    if (CASKeyDeviceSystemMajorVersion() >= 7) {
        [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithClass:UIImage.class], [CASArgumentDescriptor argWithName:@"barPosition" valuesByName:barPositionMap], [CASArgumentDescriptor argWithName:@"barMetrics" valuesByName:barMetricsMap]] setter:@selector(setBackgroundImage:forBarPosition:barMetrics:) forPropertyKey:@"backgroundImage"];
    }

    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithClass:UIImage.class], [CASArgumentDescriptor argWithName:@"state" valuesByName:controlStateMap]] setter:@selector(setSearchFieldBackgroundImage:forState:) forPropertyKey:@"searchFieldBackgroundImage"];

    NSDictionary *searchBarIconMap = @{
        @"search"       : @(UISearchBarIconSearch),
        @"clear"        : @(UISearchBarIconClear),
        @"bookmark"     : @(UISearchBarIconBookmark),
        @"resultsList"  : @(UISearchBarIconResultsList),
    };

    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithClass:UIImage.class], [CASArgumentDescriptor argWithName:@"icon" valuesByName:searchBarIconMap], [CASArgumentDescriptor argWithName:@"state" valuesByName:controlStateMap]] setter:@selector(setImage:forSearchBarIcon:state:) forPropertyKey:@"iconImage"];

    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithClass:UIImage.class], [CASArgumentDescriptor argWithName:@"state" valuesByName:controlStateMap]] setter:@selector(setScopeBarButtonBackgroundImage:forState:) forPropertyKey:@"scopeBarButtonBackgroundImage"];

    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithClass:UIImage.class], [CASArgumentDescriptor argWithName:@"leftSegmentState" valuesByName:controlStateMap], [CASArgumentDescriptor argWithName:@"rightSegmentState" valuesByName:controlStateMap]] setter:@selector(setScopeBarButtonDividerImage:forLeftSegmentState:rightSegmentState:) forPropertyKey:@"scopeBarButtonDividerImage"];

    [viewClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithObjCType:@encode(UIOffset)], [CASArgumentDescriptor argWithName:@"icon" valuesByName:searchBarIconMap]] setter:@selector(setPositionAdjustment:forSearchBarIcon:) forPropertyKey:@"iconPositionAdjustment"];
}

- (CASViewClassDescriptor *)viewClassDescriptorForClass:(Class)class {
    CASViewClassDescriptor *viewClassDescriptor = [self.viewClassDescriptorCache objectForKey:class];
    if (!viewClassDescriptor) {
        viewClassDescriptor = [[CASViewClassDescriptor alloc] initWithClass:class];
        if (class.superclass && ![UIResponder.class isSubclassOfClass:class.superclass]) {
            viewClassDescriptor.parent = [self viewClassDescriptorForClass:class.superclass];
        }
        [self.viewClassDescriptorCache setObject:viewClassDescriptor forKey:class];
    }
    return viewClassDescriptor;
}

#pragma mark - file watcher

- (void)setWatchFilePath:(NSString *)watchFilePath {
    _watchFilePath = watchFilePath;
    self.filePath = watchFilePath;

    [self.class watchForChangesToFilePath:watchFilePath withCallback:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // reload styles
            _filePath = nil;
            self.filePath = watchFilePath;

            // reapply styles
            for (UIWindow *window in UIApplication.sharedApplication.windows) {
                [self styleSubviewsOfView:window];
            }
        });
    }];
}

- (void)styleSubviewsOfView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        [self styleItem:subview];
        [self styleSubviewsOfView:subview];
    }
}

+ (void)watchForChangesToFilePath:(NSString *)filePath withCallback:(dispatch_block_t)callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    int fileDescriptor = open([filePath UTF8String], O_EVTONLY);

    NSAssert(fileDescriptor > 0, @"Error could subscribe to events for file at path: %@", filePath);

    __block dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fileDescriptor,
                                                              DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND,
                                                              queue);
    dispatch_source_set_event_handler(source, ^{
        unsigned long flags = dispatch_source_get_data(source);
        if (flags) {
            dispatch_source_cancel(source);
            callback();
            [self watchForChangesToFilePath:filePath withCallback:callback];
        }
    });
    dispatch_source_set_cancel_handler(source, ^(void){
        close(fileDescriptor);
    });
    dispatch_resume(source);
}

@end
