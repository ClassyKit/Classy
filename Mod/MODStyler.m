//
//  MODStyler.m
//  Mod
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODStyler.h"
#import "MODParser.h"
#import "MODStyleSelector.h"
#import "MODPropertyDescriptor.h"
#import "UIView+MODAdditions.h"
#import "UITextField+MODAdditions.h"
#import "MODLog.h"

@interface MODStyler ()

@property (nonatomic, strong) NSMutableArray *styles;
@property (nonatomic, strong) NSMapTable *viewClassDescriptorCache;

@end

@implementation MODStyler

- (id)initWithFilePath:(NSString *)filePath error:(NSError **)error {
    self = [super init];
    if (!self) return nil;

    self.styles = [[MODParser stylesFromFilePath:filePath error:error] mutableCopy];

    // order descending by precedence
    [self.styles sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(MODStyleSelector *s1, MODStyleSelector *s2) {
        if (s1.precedence == s2.precedence) return NSOrderedSame;
        if (s1.precedence <  s2.precedence) return NSOrderedDescending;
        return NSOrderedAscending;
    }];

    self.viewClassDescriptorCache = NSMapTable.strongToStrongObjectsMapTable;
    [self setupViewClassDescriptors];

    // precompute values
    for (MODStyleSelector *styleSelector in self.styles.reverseObjectEnumerator) {
        for (MODStyleProperty *styleProperty in styleSelector.node.properties) {
            // TODO type checking and throw errors

            // ensure we dont do same node twice
            // TODO each styleSelector should really have its own node.
            if (styleProperty.invocation) continue;

            MODViewClassDescriptor *viewClassDescriptor = [self viewClassDescriptorForClass:styleSelector.viewClass];
            MODPropertyDescriptor *propertyDescriptor = [viewClassDescriptor propertyDescriptorForKey:styleProperty.name];

            NSInvocation *invocation = [viewClassDescriptor invocationForPropertyDescriptor:propertyDescriptor];
            [invocation retainArguments];
            [propertyDescriptor.argumentDescriptors enumerateObjectsUsingBlock:^(MODArgumentDescriptor *argDescriptor, NSUInteger idx, BOOL *stop) {
                NSInteger argIndex = 2 + idx;
                switch (argDescriptor.primitiveType) {
                    case MODPrimitiveTypeBOOL: {
                        BOOL value = [[styleProperty valueOfTokenType:MODTokenTypeBoolean] boolValue];
                        [invocation setArgument:&value atIndex:argIndex];
                        break;
                    }
                    case MODPrimitiveTypeInteger: {
                        NSInteger value;
                        if (argDescriptor.valuesByName) {
                            NSString *valueName = [styleProperty valueOfTokenType:MODTokenTypeRef];
                            value = [argDescriptor.valuesByName[valueName] integerValue];
                        } else {
                            value = [[styleProperty valueOfTokenType:MODTokenTypeUnit] integerValue];
                        }
                        [invocation setArgument:&value atIndex:argIndex];
                        break;
                    }
                    case MODPrimitiveTypeDouble: {
                        CGFloat value = [[styleProperty valueOfTokenType:MODTokenTypeUnit] doubleValue];
                        [invocation setArgument:&value atIndex:argIndex];
                        break;
                    }
                    case MODPrimitiveTypeCGSize: {
                        CGSize size;
                        [styleProperty transformValuesToCGSize:&size];
                        [invocation setArgument:&size atIndex:argIndex];
                        break;
                    }
                    case MODPrimitiveTypeUIEdgeInsets: {
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

                    NSString *imageName = [styleProperty valueOfTokenType:MODTokenTypeString] ?: [styleProperty valueOfTokenType:MODTokenTypeRef];
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
    MODViewClassDescriptor *viewClassDescriptor = [self viewClassDescriptorForClass:UIView.class];
    viewClassDescriptor.propertyKeyAliases = @{
        @"borderColor"   : @mod_propertykey(UIView, mod_borderColor),
        @"borderWidth"   : @mod_propertykey(UIView, mod_borderWidth),
        @"borderRadius"  : @mod_propertykey(UIView, mod_cornerRadius),
        @"shadowColor"   : @mod_propertykey(UIView, mod_shadowColor),
        @"shadowOffset"  : @mod_propertykey(UIView, mod_shadowOffset),
        @"shadowOpacity" : @mod_propertykey(UIView, mod_shadowOpacity),
        @"shadowRadius"  : @mod_propertykey(UIView, mod_shadowRadius),
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
    [viewClassDescriptor setPropertyType:[MODArgumentDescriptor argWithValuesByName:contentModeMap]
                                  forKey:@mod_propertykey(UIView, contentMode)];

    // some properties don't show up via reflection so we need to add them manually
    [viewClassDescriptor setPropertyType:[MODArgumentDescriptor argWithClass:UIColor.class]
                                  forKey:@mod_propertykey(UIView, backgroundColor)];

    // UITextField
    // TODO text insets
    // TODO border insets
    viewClassDescriptor = [self viewClassDescriptorForClass:UITextField.class];
    viewClassDescriptor.propertyKeyAliases = @{
        @"fontColor"           : @mod_propertykey(UITextField, textColor),
        @"fontName"            : @mod_propertykey(UITextField, mod_fontName),
        @"fontSize"            : @mod_propertykey(UITextField, mod_fontSize),
        @"horizontalAlignment" : @mod_propertykey(UITextField, textAlignment),
        @"backgroundImage"     : @mod_propertykey(UITextField, background),
        @"textInsets"          : @mod_propertykey(UITextField, mod_textEdgeInsets),
    };

    NSDictionary *textAlignmentMap = @{
        @"center"    : @(NSTextAlignmentCenter),
        @"left"      : @(NSTextAlignmentLeft),
        @"right"     : @(NSTextAlignmentRight),
        @"justified" : @(NSTextAlignmentJustified),
        @"natural"   : @(NSTextAlignmentNatural),
    };
    [viewClassDescriptor setPropertyType:[MODArgumentDescriptor argWithValuesByName:textAlignmentMap]
                                  forKey:@mod_propertykey(UITextField, textAlignment)];

    NSDictionary *borderStyleMap = @{
        @"none"    : @(UITextBorderStyleNone),
        @"line"    : @(UITextBorderStyleLine),
        @"bezel"   : @(UITextBorderStyleBezel),
        @"rounded" : @(UITextBorderStyleRoundedRect),
    };
    [viewClassDescriptor setPropertyType:[MODArgumentDescriptor argWithValuesByName:borderStyleMap]
                                  forKey:@mod_propertykey(UITextField, borderStyle)];

    
    // UIControl
    viewClassDescriptor = [self viewClassDescriptorForClass:UIControl.class];

    NSDictionary *contentVerticalAlignmentMap = @{
        @"center" : @(UIControlContentVerticalAlignmentCenter),
        @"top"    : @(UIControlContentVerticalAlignmentTop),
        @"bottom" : @(UIControlContentVerticalAlignmentBottom),
        @"fill"   : @(UIControlContentVerticalAlignmentFill),
    };
    [viewClassDescriptor setPropertyType:[MODArgumentDescriptor argWithValuesByName:contentVerticalAlignmentMap]
                                  forKey:@mod_propertykey(UIControl, contentVerticalAlignment)];

    NSDictionary *contentHorizontalAlignmentMap = @{
        @"center" : @(UIControlContentHorizontalAlignmentCenter),
        @"left"   : @(UIControlContentHorizontalAlignmentLeft),
        @"right"  : @(UIControlContentHorizontalAlignmentRight),
        @"fill"   : @(UIControlContentHorizontalAlignmentFill),
    };
    [viewClassDescriptor setPropertyType:[MODArgumentDescriptor argWithValuesByName:contentHorizontalAlignmentMap]
                                  forKey:@mod_propertykey(UIControl, contentHorizontalAlignment)];
}

- (void)styleView:(UIView *)view {
    // TODO style lookup table to improve speed.

    for (MODStyleSelector *styleSelector in self.styles.reverseObjectEnumerator) {
        if ([styleSelector shouldSelectView:view]) {
            // apply style nodes
            for (MODStyleProperty *styleProperty in styleSelector.node.properties) {
                [styleProperty.invocation invokeWithTarget:view];
            }
        }
    }
}

- (MODViewClassDescriptor *)viewClassDescriptorForClass:(Class)class {
    MODViewClassDescriptor *viewClassDescriptor = [self.viewClassDescriptorCache objectForKey:class];
    if (!viewClassDescriptor) {
        viewClassDescriptor = [[MODViewClassDescriptor alloc] initWithClass:class];
        if (class.superclass && ![UIResponder.class isSubclassOfClass:class.superclass]) {
            viewClassDescriptor.parent = [self viewClassDescriptorForClass:class.superclass];
        }
        [self.viewClassDescriptorCache setObject:viewClassDescriptor forKey:class];
    }
    return viewClassDescriptor;
}

@end
