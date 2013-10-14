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

@interface NSArray ()

- (id)firstObject;

@end

@interface MODStyler ()

@property (nonatomic, strong) NSMutableArray *styles;
@property (nonatomic, strong) NSMapTable *viewClassDescriptorCache;

@end

@implementation MODStyler

- (id)initWithFilePath:(NSString *)filePath error:(NSError **)error {
    self = [super init];
    if (!self) return nil;

    self.styles = [[MODParser stylesFromFilePath:filePath error:error] mutableCopy];

    //order descending by precedence
    [self.styles sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(MODStyleSelector *s1, MODStyleSelector *s2) {
        if (s1.precedence == s2.precedence) return NSOrderedSame;
        if (s1.precedence <  s2.precedence) return NSOrderedDescending;
        return NSOrderedAscending;
    }];

    self.viewClassDescriptorCache = NSMapTable.strongToStrongObjectsMapTable;
    [self setupViewClassDescriptors];

    //precompute values
    for (MODStyleSelector *styleSelector in self.styles.reverseObjectEnumerator) {
        for (MODStyleProperty *styleProperty in styleSelector.node.properties) {
            //TODO type checking and throw errors

            //ensure we dont do same node twice
            if (styleProperty.invocation) continue;

            MODViewClassDescriptor *viewClassDescriptor = [self viewClassDescriptorForClass:styleSelector.viewClass];
            MODPropertyDescriptor *propertyDescriptor = [viewClassDescriptor propertyDescriptorForKey:styleProperty.name];

            NSInvocation *invocation = [viewClassDescriptor invocationForPropertyDescriptor:propertyDescriptor];
            [propertyDescriptor.argumentDescriptors enumerateObjectsUsingBlock:^(MODArgumentDescriptor *argDescriptor, NSUInteger idx, BOOL *stop) {
                NSInteger argIndex = 2 + idx;
                if (argDescriptor.primitiveType == MODPrimitiveTypeInteger) {
                    NSInteger value;
                    if (argDescriptor.valuesByName) {
                        value = [argDescriptor.valuesByName[styleProperty.values.firstObject] integerValue];
                    } else {
                        value = [styleProperty.values.lastObject integerValue];
                    }
                    [invocation setArgument:&value atIndex:argIndex];
                } else if (argDescriptor.primitiveType == MODPrimitiveTypeDouble) {
                    CGFloat value = [styleProperty.values.firstObject doubleValue];
                    [invocation setArgument:&value atIndex:argIndex];
                } else if (argDescriptor.primitiveType == MODPrimitiveTypeCGSize) {
                    __block CGSize size;
                    __block BOOL hasWidth = NO, hasHeight = NO;
                    [styleProperty.valueTokens enumerateObjectsUsingBlock:^(MODToken *token, NSUInteger idx, BOOL *stop) {
                        if (token.type == MODTokenTypeUnit) {
                            if (!hasWidth) {
                                size.width = [token.value doubleValue];
                                size.height = [token.value doubleValue];
                                hasWidth = YES;
                            } else if (!hasHeight) {
                                size.height = [token.value doubleValue];
                                hasHeight = YES;
                            }
                        }
                    }];
                    [invocation setArgument:&size atIndex:argIndex];
                } else if (argDescriptor.class) {
                    id value = [styleProperty.values lastObject];
                    [invocation setArgument:&value atIndex:argIndex];
                }
            }];
            [invocation retainArguments];
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

    //some properties don't show up via reflection so we need to add them manually
    [viewClassDescriptor setPropertyType:[MODArgumentDescriptor argWithClass:UIColor.class]
                                  forKey:@mod_propertykey(UIView, backgroundColor)];

    // UITextField
    viewClassDescriptor = [self viewClassDescriptorForClass:UITextField.class];
    viewClassDescriptor.propertyKeyAliases = @{
        @"fontColor"             : @mod_propertykey(UITextField, textColor),
        @"fontName"              : @mod_propertykey(UITextField, mod_fontName),
        @"fontSize"              : @mod_propertykey(UITextField, mod_fontSize),
        @"horizontalAlignment"   : @mod_propertykey(UITextField, textAlignment),
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
    //TODO style lookup table to improve speed.

    for (MODStyleSelector *styleSelector in self.styles.reverseObjectEnumerator) {
        if ([styleSelector shouldSelectView:view]) {
            //apply style nodes
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
