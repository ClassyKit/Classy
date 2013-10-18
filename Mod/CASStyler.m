//
//  CASStyler.m
//  Classy
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASStyler.h"
#import "CASParser.h"
#import "CASStyleSelector.h"
#import "CASPropertyDescriptor.h"
#import "UIView+CASAdditions.h"
#import "UITextField+CASAdditions.h"
#import "CASLog.h"

@interface CASStyler ()

@property (nonatomic, strong) NSMutableArray *styles;
@property (nonatomic, strong) NSMapTable *viewClassDescriptorCache;

@end

@implementation CASStyler

- (id)initWithFilePath:(NSString *)filePath error:(NSError **)error {
    self = [super init];
    if (!self) return nil;

    self.styles = [[CASParser stylesFromFilePath:filePath error:error] mutableCopy];

    // order descending by precedence
    [self.styles sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(CASStyleSelector *s1, CASStyleSelector *s2) {
        if (s1.precedence == s2.precedence) return NSOrderedSame;
        if (s1.precedence <  s2.precedence) return NSOrderedDescending;
        return NSOrderedAscending;
    }];

    self.viewClassDescriptorCache = NSMapTable.strongToStrongObjectsMapTable;
    [self setupViewClassDescriptors];

    // precompute values
    for (CASStyleSelector *styleSelector in self.styles.reverseObjectEnumerator) {
        for (CASStyleProperty *styleProperty in styleSelector.node.properties) {
            // TODO type checking and throw errors

            // ensure we dont do same node twice
            if (styleProperty.invocation) continue;

            CASViewClassDescriptor *viewClassDescriptor = [self viewClassDescriptorForClass:styleSelector.viewClass];
            CASPropertyDescriptor *propertyDescriptor = [viewClassDescriptor propertyDescriptorForKey:styleProperty.name];

            NSInvocation *invocation = [viewClassDescriptor invocationForPropertyDescriptor:propertyDescriptor];
            [invocation retainArguments];
            [propertyDescriptor.argumentDescriptors enumerateObjectsUsingBlock:^(CASArgumentDescriptor *argDescriptor, NSUInteger idx, BOOL *stop) {
                NSInteger argIndex = 2 + idx;
                switch (argDescriptor.primitiveType) {
                    case CASPrimitiveTypeBOOL: {
                        BOOL value = [[styleProperty valueOfTokenType:CASTokenTypeBoolean] boolValue];
                        [invocation setArgument:&value atIndex:argIndex];
                        break;
                    }
                    case CASPrimitiveTypeInteger: {
                        NSInteger value;
                        if (argDescriptor.valuesByName) {
                            NSString *valueName = [styleProperty valueOfTokenType:CASTokenTypeRef];
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
                    default:
                        break;
                }

                if (argDescriptor.argumentClass == UIImage.class) {
                    UIEdgeInsets insets;
                    BOOL hasInsets = [styleProperty transformValuesToUIEdgeInsets:&insets];

                    NSString *imageName = [styleProperty valueOfTokenType:CASTokenTypeString] ?: [styleProperty valueOfTokenType:CASTokenTypeRef];
                    UIImage *image = [UIImage imageNamed:imageName];
                    if (hasInsets) {
                        image = [image resizableImageWithCapInsets:insets];
                    }
                    if (image) {
                        [invocation setArgument:&image atIndex:argIndex];
                    }
                } else if (argDescriptor.argumentClass) {
                    id value = styleProperty.values.count ? styleProperty.values[0] : nil;
                    [invocation setArgument:&value atIndex:argIndex];
                }
            }];
            styleProperty.invocation = invocation;
        }
    }

    return self;
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
    [viewClassDescriptor setPropertyType:[CASArgumentDescriptor argWithValuesByName:contentModeMap]
                                  forKey:@cas_propertykey(UIView, contentMode)];

    // some properties don't show up via reflection so we need to add them manually
    [viewClassDescriptor setPropertyType:[CASArgumentDescriptor argWithClass:UIColor.class]
                                  forKey:@cas_propertykey(UIView, backgroundColor)];

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
    [viewClassDescriptor setPropertyType:[CASArgumentDescriptor argWithValuesByName:textAlignmentMap]
                                  forKey:@cas_propertykey(UITextField, textAlignment)];

    NSDictionary *borderStyleMap = @{
        @"none"    : @(UITextBorderStyleNone),
        @"line"    : @(UITextBorderStyleLine),
        @"bezel"   : @(UITextBorderStyleBezel),
        @"rounded" : @(UITextBorderStyleRoundedRect),
    };
    [viewClassDescriptor setPropertyType:[CASArgumentDescriptor argWithValuesByName:borderStyleMap]
                                  forKey:@cas_propertykey(UITextField, borderStyle)];

    
    // UIControl
    viewClassDescriptor = [self viewClassDescriptorForClass:UIControl.class];

    NSDictionary *contentVerticalAlignmentMap = @{
        @"center" : @(UIControlContentVerticalAlignmentCenter),
        @"top"    : @(UIControlContentVerticalAlignmentTop),
        @"bottom" : @(UIControlContentVerticalAlignmentBottom),
        @"fill"   : @(UIControlContentVerticalAlignmentFill),
    };
    [viewClassDescriptor setPropertyType:[CASArgumentDescriptor argWithValuesByName:contentVerticalAlignmentMap]
                                  forKey:@cas_propertykey(UIControl, contentVerticalAlignment)];

    NSDictionary *contentHorizontalAlignmentMap = @{
        @"center" : @(UIControlContentHorizontalAlignmentCenter),
        @"left"   : @(UIControlContentHorizontalAlignmentLeft),
        @"right"  : @(UIControlContentHorizontalAlignmentRight),
        @"fill"   : @(UIControlContentHorizontalAlignmentFill),
    };
    [viewClassDescriptor setPropertyType:[CASArgumentDescriptor argWithValuesByName:contentHorizontalAlignmentMap]
                                  forKey:@cas_propertykey(UIControl, contentHorizontalAlignment)];
}

- (void)styleView:(UIView *)view {
    // TODO style lookup table to improve speed.

    for (CASStyleSelector *styleSelector in self.styles.reverseObjectEnumerator) {
        if ([styleSelector shouldSelectView:view]) {
            // apply style nodes
            for (CASStyleProperty *styleProperty in styleSelector.node.properties) {
                [styleProperty.invocation invokeWithTarget:view];
            }
        }
    }
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

@end
