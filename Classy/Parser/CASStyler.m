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
#import "CASTextAttributes.h"
#import "CASInvocation.h"

@interface CASStyler ()

@property (nonatomic, strong) NSMutableArray *styleNodes;
@property (nonatomic, strong) NSMapTable *objectClassDescriptorCache;
@property (nonatomic, strong) NSHashTable *scheduledItems;
@property (nonatomic, strong) NSTimer *updateTimer;

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

    self.objectClassDescriptorCache = NSMapTable.strongToStrongObjectsMapTable;
    self.scheduledItems = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    [self setupObjectClassDescriptors];

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
            for (CASInvocation *invocation in styleNode.invocations) {
                [invocation invokeWithTarget:item];
            }
        }
    }
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

    CASParser *parser = [CASParser parserFromFilePath:filePath error:error];
    NSArray *styleNodes = parser.styleNodes;

    if (self.watchFilePath) {
        NSString *directoryPath = [self.watchFilePath stringByDeletingLastPathComponent];
        for (NSString *fileName in parser.importedFileNames) {
            NSString *resolvedPath = [directoryPath stringByAppendingPathComponent:fileName];
            [self reloadOnChangesToFilePath:resolvedPath];
        }
    }


    if (!styleNodes.count) {
        return;
    }

    // filter redundant nodes
    NSMutableArray *filteredNodes = NSMutableArray.new;
    for (CASStyleNode *styleNode in styleNodes) {
        // invalid if does not have any properties
        BOOL invalid = !styleNode.styleProperties.count;
        
        // invalid if has deviceSelector and deviceSelector is not valid
        invalid = invalid || (styleNode.deviceSelector && !styleNode.deviceSelector.isValid);
        if (!invalid) {
            [filteredNodes addObject:styleNode];
        }
    }
    self.styleNodes = filteredNodes;

    // order descending by precedence
    [self.styleNodes sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(CASStyleNode *n1, CASStyleNode *n2) {
        if (n1.styleSelector.precedence == n2.styleSelector.precedence) return NSOrderedSame;
        if (n1.styleSelector.precedence <  n2.styleSelector.precedence) return NSOrderedDescending;
        return NSOrderedAscending;
    }];

    // precompute values
    for (CASStyleNode *styleNode in self.styleNodes.reverseObjectEnumerator) {
        NSMutableArray *invocations = NSMutableArray.new;
        for (CASStyleProperty *styleProperty in styleNode.styleProperties) {
            // TODO type checking and throw errors
            NSArray *propertyInvocations = [self invocationsForClass:styleNode.styleSelector.objectClass styleProperty:styleProperty keyPath:nil];
            [invocations addObjectsFromArray:propertyInvocations];
        }
        styleNode.invocations = invocations;
    }
}

#pragma mark - private

- (NSArray *)invocationsForClass:(Class)aClass styleProperty:(CASStyleProperty *)styleProperty keyPath:(NSString *)keypath {
    CASObjectClassDescriptor *objectClassDescriptor = [self objectClassDescriptorForClass:aClass];
    CASPropertyDescriptor *propertyDescriptor = [objectClassDescriptor propertyDescriptorForKey:styleProperty.name];

    //Special case textAttributes
    BOOL isTextAttributesProperty = styleProperty.childStyleProperties.count && [styleProperty.name hasSuffix:@"TextAttributes"];

    NSInvocation *invocation;
    CASInvocation *invocationWrapper;;
    NSMutableArray *invocations = NSMutableArray.new;
    if (isTextAttributesProperty || !styleProperty.childStyleProperties.count) {
        invocation = [objectClassDescriptor invocationForPropertyDescriptor:propertyDescriptor];
        [invocation retainArguments];
        invocationWrapper = [[CASInvocation alloc] initWithInvocation:invocation forKeyPath:keypath];
        [invocations addObject:invocationWrapper];
    }

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
            case CASPrimitiveTypeCGRect: {
                CGRect rect;
                [styleProperty transformValuesToCGRect:&rect];
                [invocation setArgument:&rect atIndex:argIndex];
                break;
            }
            case CASPrimitiveTypeCGPoint: {
                CGPoint point;
                [styleProperty transformValuesToCGPoint:&point];
                [invocation setArgument:&point atIndex:argIndex];
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
            case CASPrimitiveTypeCGColorRef : {
                UIColor *color = nil;
                [styleProperty transformValuesToUIColor:&color];
                CGColorRef colorRef = color.CGColor;
                [invocation setArgument:&colorRef atIndex:argIndex];
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
        } else if (argDescriptor.argumentClass == UIFont.class) {
            UIFont *font = nil;
            [styleProperty transformValuesToUIFont:&font];
            [invocation setArgument:&font atIndex:argIndex];
        }

        if (styleProperty.childStyleProperties.count) {
            id target = nil;
            Class targetClass = argDescriptor.argumentClass;

            NSString *childKeyPath = keypath.length ? [NSString stringWithFormat:@"%@.%@", keypath, styleProperty.name] : styleProperty.name;

            // handle textAttributes as special case
            BOOL isTextAttributesArg = targetClass == NSDictionary.class && isTextAttributesProperty;
            if (isTextAttributesArg) {
                target = CASTextAttributes.new;
                targetClass = CASTextAttributes.class;
                childKeyPath = nil;
            }

            for (CASStyleProperty *childStyleProperty in styleProperty.childStyleProperties) {
                NSArray *childInvocations = [self invocationsForClass:targetClass styleProperty:childStyleProperty keyPath:childKeyPath];
                
                if (target) {
                    [childInvocations makeObjectsPerformSelector:@selector(invokeWithTarget:) withObject:target];
                } else {
                    [invocations addObjectsFromArray:childInvocations];
                }
            }

            // if textAttributes set argument to dictionary value
            if (isTextAttributesArg) {
                NSDictionary *value = [target dictionary];
                [invocation setArgument:&value atIndex:argIndex];
            }
        }
    }];
    return invocations;
}

- (void)setupObjectClassDescriptors {

    // Common ENUM maps
    NSDictionary *controlStateMap = @{
        @"normal"       : @(UIControlStateNormal),
        @"highlighted"  : @(UIControlStateHighlighted),
        @"disabled"     : @(UIControlStateDisabled),
        @"selected"     : @(UIControlStateSelected),
    };

    NSDictionary *textAlignmentMap = @{
        @"center"    : @(NSTextAlignmentCenter),
        @"left"      : @(NSTextAlignmentLeft),
        @"right"     : @(NSTextAlignmentRight),
        @"justified" : @(NSTextAlignmentJustified),
        @"natural"   : @(NSTextAlignmentNatural),
    };

    NSDictionary *lineBreakModeMap = @{
        @"wordWrapping"     : @(NSLineBreakByWordWrapping),
        @"charWrapping"     : @(NSLineBreakByCharWrapping),
        @"clipping"         : @(NSLineBreakByClipping),
        @"truncatingHead"   : @(NSLineBreakByTruncatingHead),
        @"truncatingTail"   : @(NSLineBreakByTruncatingTail),
        @"truncatingMiddle" : @(NSLineBreakByTruncatingMiddle)
    };

    NSDictionary *barMetricsMap = @{
        @"default"                : @(UIBarMetricsDefault),
        @"landscapePhone"        : @(UIBarMetricsLandscapePhone),
        @"defaultPrompt"         : @(UIBarMetricsDefaultPrompt),
        @"landscapePhonePrompt" : @(UIBarMetricsLandscapePhonePrompt),
    };

    NSDictionary *searchBarIconMap = @{
        @"search"       : @(UISearchBarIconSearch),
        @"clear"        : @(UISearchBarIconClear),
        @"bookmark"     : @(UISearchBarIconBookmark),
        @"resultsList"  : @(UISearchBarIconResultsList),
    };

    NSDictionary *barPositionMap = @{
        @"any"          : @(UIBarPositionAny),
        @"bottom"       : @(UIBarPositionBottom),
        @"top"          : @(UIBarPositionTop),
        @"topAttached"  : @(UIBarPositionTopAttached),
    };

    // Common CASArgumentDescriptors
    CASArgumentDescriptor *colorArg = [CASArgumentDescriptor argWithClass:UIColor.class];
    CASArgumentDescriptor *dictionaryArg = [CASArgumentDescriptor argWithClass:NSDictionary.class];
    CASArgumentDescriptor *textAlignmentArg = [CASArgumentDescriptor argWithValuesByName:textAlignmentMap];
    CASArgumentDescriptor *lineBreakModeArg = [CASArgumentDescriptor argWithValuesByName:lineBreakModeMap];
    CASArgumentDescriptor *stateArg = [CASArgumentDescriptor argWithName:@"state" valuesByName:controlStateMap];
    CASArgumentDescriptor *imageArg = [CASArgumentDescriptor argWithClass:UIImage.class];
    CASArgumentDescriptor *barMetricsArg = [CASArgumentDescriptor argWithName:@"barMetrics" valuesByName:barMetricsMap];
    CASArgumentDescriptor *floatArg = [CASArgumentDescriptor argWithObjCType:@encode(CGFloat)];
    CASArgumentDescriptor *offsetArg = [CASArgumentDescriptor argWithObjCType:@encode(UIOffset)];
    CASArgumentDescriptor *searchIconArg = [CASArgumentDescriptor argWithName:@"icon" valuesByName:searchBarIconMap];

    CASArgumentDescriptor *barPositionArg = [CASArgumentDescriptor argWithName:@"barPosition" valuesByName:barPositionMap];

    // UIView
    CASObjectClassDescriptor *objectClassDescriptor = [self objectClassDescriptorForClass:UIView.class];

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
    [objectClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithValuesByName:contentModeMap]] forPropertyKey:@cas_propertykey(UIView, contentMode)];

    // some properties don't show up via reflection so we need to add them manually
    [objectClassDescriptor setArgumentDescriptors:@[colorArg] forPropertyKey:@cas_propertykey(UIView, backgroundColor)];
    [objectClassDescriptor setArgumentDescriptors:@[colorArg] forPropertyKey:@cas_propertykey(UIView, tintColor)];

    // UIBarItem
    objectClassDescriptor = [self objectClassDescriptorForClass:UIBarItem.class];
    [objectClassDescriptor setArgumentDescriptors:@[dictionaryArg, stateArg] setter:@selector(setTitleTextAttributes:forState:) forPropertyKey:@"titleTextAttributes"];

    // UILabel
    objectClassDescriptor = [self objectClassDescriptorForClass:UILabel.class];
    [objectClassDescriptor setArgumentDescriptors:@[lineBreakModeArg] forPropertyKey:@cas_propertykey(UILabel, lineBreakMode)];
    [objectClassDescriptor setArgumentDescriptors:@[textAlignmentArg] forPropertyKey:@cas_propertykey(UILabel, textAlignment)];

    // UITextField
    // TODO border insets
    objectClassDescriptor = [self objectClassDescriptorForClass:UITextField.class];
    objectClassDescriptor.propertyKeyAliases = @{
        @"backgroundImage"     : @cas_propertykey(UITextField, background),
        @"textInsets"          : @cas_propertykey(UITextField, cas_textEdgeInsets),
    };

    [objectClassDescriptor setArgumentDescriptors:@[textAlignmentArg] forPropertyKey:@cas_propertykey(UITextField, textAlignment)];

    NSDictionary *borderStyleMap = @{
        @"none"    : @(UITextBorderStyleNone),
        @"line"    : @(UITextBorderStyleLine),
        @"bezel"   : @(UITextBorderStyleBezel),
        @"rounded" : @(UITextBorderStyleRoundedRect),
    };
    [objectClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithValuesByName:borderStyleMap]] forPropertyKey:@cas_propertykey(UITextField, borderStyle)];

    NSDictionary *textFieldViewModeMap = @{
        @"never"           : @(UITextFieldViewModeNever),
        @"whileEditing"    : @(UITextFieldViewModeWhileEditing),
        @"unlessEditing"   : @(UITextFieldViewModeUnlessEditing),
        @"always"          : @(UITextFieldViewModeAlways),
    };
    [objectClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithValuesByName:textFieldViewModeMap]] forPropertyKey:@cas_propertykey(UITextField, leftViewMode)];
    [objectClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithValuesByName:textFieldViewModeMap]] forPropertyKey:@cas_propertykey(UITextField, rightViewMode)];
    [objectClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithValuesByName:textFieldViewModeMap]] forPropertyKey:@cas_propertykey(UITextField, clearButtonMode)];
    
    // UIControl
    objectClassDescriptor = [self objectClassDescriptorForClass:UIControl.class];

    NSDictionary *contentVerticalAlignmentMap = @{
        @"center" : @(UIControlContentVerticalAlignmentCenter),
        @"top"    : @(UIControlContentVerticalAlignmentTop),
        @"bottom" : @(UIControlContentVerticalAlignmentBottom),
        @"fill"   : @(UIControlContentVerticalAlignmentFill),
    };
    [objectClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithValuesByName:contentVerticalAlignmentMap]] forPropertyKey:@cas_propertykey(UIControl, contentVerticalAlignment)];

    NSDictionary *contentHorizontalAlignmentMap = @{
        @"center" : @(UIControlContentHorizontalAlignmentCenter),
        @"left"   : @(UIControlContentHorizontalAlignmentLeft),
        @"right"  : @(UIControlContentHorizontalAlignmentRight),
        @"fill"   : @(UIControlContentHorizontalAlignmentFill),
    };
    [objectClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithValuesByName:contentHorizontalAlignmentMap]] forPropertyKey:@cas_propertykey(UIControl, contentHorizontalAlignment)];

    // UIButton
    objectClassDescriptor = [self objectClassDescriptorForClass:UIButton.class];

    [objectClassDescriptor setArgumentDescriptors:@[colorArg, stateArg] setter:@selector(setTitleColor:forState:) forPropertyKey:@"titleColor"];

    [objectClassDescriptor setArgumentDescriptors:@[colorArg, stateArg] setter:@selector(setTitleShadowColor:forState:) forPropertyKey:@"titleShadowColor"];

    [objectClassDescriptor setArgumentDescriptors:@[imageArg, stateArg] setter:@selector(setBackgroundImage:forState:) forPropertyKey:@"backgroundImage"];
    
    [objectClassDescriptor setArgumentDescriptors:@[imageArg, stateArg] setter:@selector(setImage:forState:) forPropertyKey:@"image"];
    
    

    // UIBarButtonItem
    objectClassDescriptor = [self objectClassDescriptorForClass:UIBarButtonItem.class];

    [objectClassDescriptor setArgumentDescriptors:@[imageArg, stateArg, barMetricsArg] setter:@selector(setBackgroundImage:forState:barMetrics:) forPropertyKey:@"backgroundImage"];

    [objectClassDescriptor setArgumentDescriptors:@[floatArg, barMetricsArg] setter:@selector(setBackgroundVerticalPositionAdjustment:forBarMetrics:) forPropertyKey:@"backgroundVerticalPositionAdjustment"];

    [objectClassDescriptor setArgumentDescriptors:@[offsetArg, barMetricsArg] setter:@selector(setTitlePositionAdjustment:forBarMetrics:) forPropertyKey:@"titlePositionAdjustment"];

    //backButton
    [objectClassDescriptor setArgumentDescriptors:@[imageArg, stateArg, barMetricsArg] setter:@selector(setBackButtonBackgroundImage:forState:barMetrics:) forPropertyKey:@"backButtonBackgroundImage"];

    [objectClassDescriptor setArgumentDescriptors:@[floatArg, barMetricsArg] setter:@selector(setBackButtonBackgroundVerticalPositionAdjustment:forBarMetrics:) forPropertyKey:@"backButtonBackgroundVerticalPositionAdjustment"];

    [objectClassDescriptor setArgumentDescriptors:@[offsetArg, barMetricsArg] setter:@selector(setBackButtonTitlePositionAdjustment:forBarMetrics:) forPropertyKey:@"backButtonTitlePositionAdjustment"];

    // UINavigationBar
    objectClassDescriptor = [self objectClassDescriptorForClass:UINavigationBar.class];
    if (CASKeyDeviceSystemMajorVersion() >= 7) {
        [objectClassDescriptor setArgumentDescriptors:@[imageArg, barPositionArg, barMetricsArg] setter:@selector(setBackgroundImage:forBarPosition:barMetrics:) forPropertyKey:@"backgroundImage"];
    } else {
        [objectClassDescriptor setArgumentDescriptors:@[imageArg, barMetricsArg] setter:@selector(setBackgroundImage:forBarMetrics:) forPropertyKey:@"backgroundImage"];
    }

    [objectClassDescriptor setArgumentDescriptors:@[floatArg, barMetricsArg] setter:@selector(setTitleVerticalPositionAdjustment:forBarMetrics:) forPropertyKey:@"titleVerticalPositionAdjustment"];

    // UISearchBar
    objectClassDescriptor = [self objectClassDescriptorForClass:UISearchBar.class];
    if (CASKeyDeviceSystemMajorVersion() >= 7) {
        [objectClassDescriptor setArgumentDescriptors:@[imageArg, barPositionArg, barMetricsArg] setter:@selector(setBackgroundImage:forBarPosition:barMetrics:) forPropertyKey:@"backgroundImage"];
    }

    [objectClassDescriptor setArgumentDescriptors:@[imageArg, stateArg] setter:@selector(setSearchFieldBackgroundImage:forState:) forPropertyKey:@"searchFieldBackgroundImage"];

    [objectClassDescriptor setArgumentDescriptors:@[imageArg, searchIconArg, stateArg] setter:@selector(setImage:forSearchBarIcon:state:) forPropertyKey:@"iconImage"];

    [objectClassDescriptor setArgumentDescriptors:@[imageArg, stateArg] setter:@selector(setScopeBarButtonBackgroundImage:forState:) forPropertyKey:@"scopeBarButtonBackgroundImage"];

    [objectClassDescriptor setArgumentDescriptors:@[imageArg, [CASArgumentDescriptor argWithName:@"leftSegmentState" valuesByName:controlStateMap], [CASArgumentDescriptor argWithName:@"rightSegmentState" valuesByName:controlStateMap]] setter:@selector(setScopeBarButtonDividerImage:forLeftSegmentState:rightSegmentState:) forPropertyKey:@"scopeBarButtonDividerImage"];

    [objectClassDescriptor setArgumentDescriptors:@[offsetArg, searchIconArg] setter:@selector(setPositionAdjustment:forSearchBarIcon:) forPropertyKey:@"iconPositionAdjustment"];

    [objectClassDescriptor setArgumentDescriptors:@[dictionaryArg, stateArg] setter:@selector(setScopeBarButtonTitleTextAttributes:forState:) forPropertyKey:@"scopeBarButtonTitleTextAttributes"];

    // UISegmentedControl
    objectClassDescriptor = [self objectClassDescriptorForClass:UISegmentedControl.class];

    [objectClassDescriptor setArgumentDescriptors:@[imageArg, stateArg, barMetricsArg] setter:@selector(setBackgroundImage:forState:barMetrics:) forPropertyKey:@"backgroundImage"];

    [objectClassDescriptor setArgumentDescriptors:@[imageArg, [CASArgumentDescriptor argWithName:@"leftSegmentState" valuesByName:controlStateMap], [CASArgumentDescriptor argWithName:@"rightSegmentState" valuesByName:controlStateMap], barMetricsArg] setter:@selector(setDividerImage:forLeftSegmentState:rightSegmentState:barMetrics:) forPropertyKey:@"dividerImage"];

    NSDictionary *segmentedControlSegmentMap = @{
        @"any"    : @(UISegmentedControlSegmentAny),
        @"left"   : @(UISegmentedControlSegmentLeft),
        @"center" : @(UISegmentedControlSegmentCenter),
        @"right"  : @(UISegmentedControlSegmentRight),
        @"alone"  : @(UISegmentedControlSegmentAlone),
    };
    [objectClassDescriptor setArgumentDescriptors:@[offsetArg, [CASArgumentDescriptor argWithName:@"segmentType" valuesByName:segmentedControlSegmentMap], barMetricsArg] setter:@selector(setContentPositionAdjustment:forSegmentType:barMetrics:) forPropertyKey:@"contentPositionAdjustment"];

    [objectClassDescriptor setArgumentDescriptors:@[dictionaryArg, stateArg] setter:@selector(setTitleTextAttributes:forState:) forPropertyKey:@"titleTextAttributes"];
    
    // UIStepper
    objectClassDescriptor = [self objectClassDescriptorForClass:UIStepper.class];

    [objectClassDescriptor setArgumentDescriptors:@[imageArg, stateArg] setter:@selector(setBackgroundImage:forState:) forPropertyKey:@"backgroundImage"];

    [objectClassDescriptor setArgumentDescriptors:@[imageArg, [CASArgumentDescriptor argWithName:@"leftSegmentState" valuesByName:controlStateMap], [CASArgumentDescriptor argWithName:@"rightSegmentState" valuesByName:controlStateMap]] setter:@selector(setDividerImage:forLeftSegmentState:rightSegmentState:) forPropertyKey:@"dividerImage"];

    [objectClassDescriptor setArgumentDescriptors:@[imageArg, stateArg] setter:@selector(setDecrementImage:forState:) forPropertyKey:@"decrementImage"];

    [objectClassDescriptor setArgumentDescriptors:@[imageArg, stateArg] setter:@selector(setIncrementImage:forState:) forPropertyKey:@"incrementImage"];

    // UITabBar
    objectClassDescriptor = [self objectClassDescriptorForClass:UITabBar.class];
    if (CASKeyDeviceSystemMajorVersion() >= 7) {
        NSDictionary *tabBarItemPositioningMap = @{
            @"auto"      : @(UITabBarItemPositioningAutomatic),
            @"automatic" : @(UITabBarItemPositioningAutomatic),
            @"fill"      : @(UITabBarItemPositioningFill),
            @"centered"  : @(UITabBarItemPositioningCentered),
        };
        [objectClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithValuesByName:tabBarItemPositioningMap]] forPropertyKey:@cas_propertykey(UITabBar, itemPositioning)];

        NSDictionary *barStyleMap = @{
            @"default" : @(UIBarStyleDefault),
            @"black"   : @(UIBarStyleBlack),
        };
        [objectClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithValuesByName:barStyleMap]] forPropertyKey:@cas_propertykey(UITabBar, barStyle)];
    }

    // UITabBarItem
    objectClassDescriptor = [self objectClassDescriptorForClass:UITabBarItem.class];
    [objectClassDescriptor setArgumentDescriptors:@[[CASArgumentDescriptor argWithObjCType:@encode(UIOffset)]] forPropertyKey:@cas_propertykey(UITabBarItem, titlePositionAdjustment)];

    // UIToolBar
    objectClassDescriptor = [self objectClassDescriptorForClass:UIToolbar.class];

    [objectClassDescriptor setArgumentDescriptors:@[imageArg, [CASArgumentDescriptor argWithName:@"toolbarPosition" valuesByName:barPositionMap], barMetricsArg] setter:@selector(setBackgroundImage:forToolbarPosition:barMetrics:) forPropertyKey:@"backgroundImage"];

    [objectClassDescriptor setArgumentDescriptors:@[imageArg, [CASArgumentDescriptor argWithName:@"toolbarPosition" valuesByName:barPositionMap]] setter:@selector(setShadowImage:forToolbarPosition:) forPropertyKey:@"shadowImage"];

    // CASTextAttributes
    objectClassDescriptor = [self objectClassDescriptorForClass:CASTextAttributes.class];

    NSDictionary *underlineStyleMap;
    if (CASKeyDeviceSystemMajorVersion() >= 7) {
        underlineStyleMap = @{
            @"none"      : @(NSUnderlineStyleNone),
            @"single"    : @(NSUnderlineStyleSingle),
            @"thick"     : @(NSUnderlineStyleThick),
            @"double"    : @(NSUnderlineStyleDouble),
            @"solid"     : @(NSUnderlinePatternSolid),
            @"dot"       : @(NSUnderlinePatternDot),
            @"dash"      : @(NSUnderlinePatternDash),
            @"dashDot"   : @(NSUnderlinePatternDashDot),
            @"dotDotDot" : @(NSUnderlinePatternDashDotDot),
            @"byWord"    : @(NSUnderlineByWord),
        };
    } else {
        underlineStyleMap = @{
            @"none"    : @(NSUnderlineStyleNone),
            @"single"  : @(NSUnderlineStyleSingle),
        };
    }

    CASArgumentDescriptor *underlineStyleArg = [CASArgumentDescriptor argWithValuesByName:underlineStyleMap];
    [objectClassDescriptor setArgumentDescriptors:@[underlineStyleArg] forPropertyKey:@cas_propertykey(CASTextAttributes, underlineStyle)];
    [objectClassDescriptor setArgumentDescriptors:@[underlineStyleArg] forPropertyKey:@cas_propertykey(CASTextAttributes, strikethroughStyle)];

    // NSParagraphStyle
    objectClassDescriptor = [self objectClassDescriptorForClass:NSParagraphStyle.class];
    [objectClassDescriptor setArgumentDescriptors:@[textAlignmentArg] forPropertyKey:@cas_propertykey(NSParagraphStyle, alignment)];
    [objectClassDescriptor setArgumentDescriptors:@[lineBreakModeArg] forPropertyKey:@cas_propertykey(NSParagraphStyle, lineBreakMode)];


    // NSShadow
    objectClassDescriptor = [self objectClassDescriptorForClass:NSShadow.class];
    [objectClassDescriptor setArgumentDescriptors:@[colorArg] forPropertyKey:@cas_propertykey(NSShadow, shadowColor)];
}

- (CASObjectClassDescriptor *)objectClassDescriptorForClass:(Class)aClass {
    CASObjectClassDescriptor *objectClassDescriptor = [self.objectClassDescriptorCache objectForKey:aClass];
    if (!objectClassDescriptor) {
        objectClassDescriptor = [[CASObjectClassDescriptor alloc] initWithClass:aClass];
        if (aClass.superclass && ![NSObject.class isSubclassOfClass:aClass.superclass] && ![UIResponder.class isSubclassOfClass:aClass.superclass]) {
            objectClassDescriptor.parent = [self objectClassDescriptorForClass:aClass.superclass];
        }
        [self.objectClassDescriptorCache setObject:objectClassDescriptor forKey:aClass];
    }
    return objectClassDescriptor;
}

#pragma mark - sceduling

- (void)updateScheduledItems {
    for (id<CASStyleableItem> item in self.scheduledItems.copy) {
        if (!item) continue;
        [item cas_updateStylingIfNeeded];
        [self.scheduledItems removeObject:item];
    }

    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

- (void)scheduleUpdateForItem:(id<CASStyleableItem>)item {
    [self.scheduledItems addObject:item];

    if (self.scheduledItems.count && !self.updateTimer.isValid) {
        self.updateTimer = [NSTimer timerWithTimeInterval:0.0 target:self selector:@selector(updateScheduledItems) userInfo:nil repeats:YES];
        [NSRunLoop.mainRunLoop addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)unscheduleUpdateForItem:(id<CASStyleableItem>)item {
    [self.scheduledItems removeObject:item];

    if (!self.scheduledItems.count == 0) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    }
}

#pragma mark - file watcher

- (void)setWatchFilePath:(NSString *)watchFilePath {
    _watchFilePath = watchFilePath;
    self.filePath = watchFilePath;

    [self reloadOnChangesToFilePath:watchFilePath];
}

- (void)reloadOnChangesToFilePath:(NSString *)filePath {
    [self.class watchForChangesToFilePath:filePath withCallback:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // reload styles
            _filePath = nil;
            self.filePath = _watchFilePath;

            // reapply styles
            for (UIWindow *window in UIApplication.sharedApplication.windows) {
                [self styleSubviewsOfView:window];
            }
        });
    }];
}

- (void)styleSubviewsOfView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        [subview cas_updateStyling];
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
