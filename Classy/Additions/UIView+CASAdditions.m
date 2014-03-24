//
//  UIView+CASAdditions.m
//  Classy
//
//  Created by Jonas Budelmann on 30/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "UIView+CASAdditions.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "NSObject+CASSwizzle.h"
#import "CASStyler.h"
#import "NSString+CASAdditions.h"

static void *CASStyleHasBeenUpdatedKey = &CASStyleHasBeenUpdatedKey;

@implementation UIView (CASAdditions)

+ (void)load {
    [self cas_swizzleInstanceSelector:@selector(didMoveToWindow)
                      withNewSelector:@selector(cas_didMoveToWindow)];
}

- (void)cas_didMoveToWindow {
    [self cas_updateStyling];

    [self cas_didMoveToWindow];
}

- (void)cas_setNeedsUpdateStylingForSubviews {
    [self cas_setNeedsUpdateStyling];
    for (UIView *view in self.subviews) {
        [view cas_setNeedsUpdateStylingForSubviews];
    }
}

#pragma mark - CASStyleableItem

- (NSString *)cas_styleClass {
    NSSet *styleClasses = self.cas_styleClasses;
    return [styleClasses.allObjects componentsJoinedByString:CASStyleClassSeparator];
}

- (void)setCas_styleClass:(NSString *)styleClass {
    NSArray *classCandidates = [styleClass componentsSeparatedByString:CASStyleClassSeparator];
    NSMutableSet *newStyleClasses = [NSMutableSet set];
    [classCandidates enumerateObjectsUsingBlock:^(NSString *styleClass, NSUInteger idx, BOOL *stop) {
        if ([styleClass isKindOfClass:NSString.class] && styleClass.length > 0) {
            [newStyleClasses addObject:styleClass];
        }
    }];
    self.cas_styleClasses = [newStyleClasses copy];
}

- (NSSet *)cas_styleClasses {
    return objc_getAssociatedObject(self, @selector(cas_styleClasses));
}

- (void)setCas_styleClasses:(NSSet *)cas_styleClasses {
    if ([self.cas_styleClasses isEqual:cas_styleClasses]) return;
    objc_setAssociatedObject(self, @selector(cas_styleClasses), cas_styleClasses, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self cas_setNeedsUpdateStylingForSubviews];
}

- (void) cas_addStyleClass:(NSString *)styleClass {
    if (styleClass.length == 0) return;
    if (self.cas_styleClasses == nil) {
        self.cas_styleClasses = [NSSet setWithObject:styleClass];
    }
    else {
        self.cas_styleClasses = [self.cas_styleClasses setByAddingObject:styleClass];
    }
    
    [self cas_setNeedsUpdateStylingForSubviews];
}

- (void)cas_removeStyleClass:(NSString *)styleClass {
    if (self.cas_styleClasses == nil || styleClass.length == 0) return;
    NSMutableSet *styleClasses = [NSMutableSet setWithSet:self.cas_styleClasses];
    [styleClasses removeObject:styleClass];
    self.cas_styleClasses = [styleClasses copy];
    
    [self cas_setNeedsUpdateStylingForSubviews];
}

- (BOOL)cas_hasStyleClass:(NSString *)styleClass {
    return [self.cas_styleClasses containsObject:styleClass];
}

- (id<CASStyleableItem>)cas_parent {
    return self.superview;
}

- (id<CASStyleableItem>)cas_alternativeParent {
    return objc_getAssociatedObject(self, @selector(cas_alternativeParent));
}

- (void)setCas_alternativeParent:(id<CASStyleableItem>)parent {
    objc_setAssociatedObject(self, @selector(cas_alternativeParent), parent, OBJC_ASSOCIATION_ASSIGN);
}

- (void)cas_updateStylingIfNeeded {
    if ([self cas_needsUpdateStyling] && self.window) {
        [self cas_updateStyling];
    }
}

- (void)cas_updateStyling {
    [CASStyler.defaultStyler styleItem:self];
    objc_setAssociatedObject(self, CASStyleHasBeenUpdatedKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [CASStyler.defaultStyler unscheduleUpdateForItem:self];
}

- (BOOL)cas_needsUpdateStyling {
    return ![objc_getAssociatedObject(self, @selector(cas_needsUpdateStyling)) boolValue];
}

- (void)cas_setNeedsUpdateStyling {
    objc_setAssociatedObject(self, CASStyleHasBeenUpdatedKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [CASStyler.defaultStyler scheduleUpdateForItem:self];
}

@end
