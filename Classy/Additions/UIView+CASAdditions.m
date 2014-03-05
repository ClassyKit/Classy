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
    return objc_getAssociatedObject(self, @selector(cas_styleClass));
}

- (void)setCas_styleClass:(NSString *)styleClass {
    if ([self.cas_styleClass isEqual:styleClass]) return;
    objc_setAssociatedObject(self, @selector(cas_styleClass), styleClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self cas_setNeedsUpdateStylingForSubviews];
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
    if ([self cas_needsUpdateStyling]) {
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
