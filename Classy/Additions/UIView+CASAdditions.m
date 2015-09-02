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
#import "CASStyleClassUtilities.h"
#import "CASAssociatedObjectsWeakWrapper.h"

static void *CASStyleHasBeenUpdatedKey = &CASStyleHasBeenUpdatedKey;

@implementation UIView (CASAdditions)

CASSynthesize(weak, id<CASStyleableItem>, cas_alternativeParent, setCas_alternativeParent);

+ (void)bootstrapClassy {
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
    return [CASStyleClassUtilities styleClassForItem:self];
}

- (void)setCas_styleClass:(NSString *)styleClass {
    [CASStyleClassUtilities setStyleClass:styleClass forItem:self];
    [self cas_setNeedsUpdateStyling];
}

- (void)cas_addStyleClass:(NSString *)styleClass {
    [CASStyleClassUtilities addStyleClass:styleClass forItem:self];
    [self cas_setNeedsUpdateStyling];
}

- (void)cas_removeStyleClass:(NSString *)styleClass {
    [CASStyleClassUtilities removeStyleClass:styleClass forItem:self];
    [self cas_setNeedsUpdateStyling];
}

- (BOOL)cas_hasStyleClass:(NSString *)styleClass {
    return [CASStyleClassUtilities item:self hasStyleClass:styleClass];
}

- (id<CASStyleableItem>)cas_parent {
    return self.superview;
}

- (void)cas_updateStylingIfNeeded {
    if ([self cas_needsUpdateStyling]) {
        [self cas_updateStyling];
    }
}

- (void)cas_updateStyling {
    if (self.window) {
        [CASStyler.defaultStyler styleItem:self];
    }
    objc_setAssociatedObject(self, CASStyleHasBeenUpdatedKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [CASStyler.defaultStyler unscheduleUpdateForItem:self];
}

- (BOOL)cas_needsUpdateStyling {
    return ![objc_getAssociatedObject(self, CASStyleHasBeenUpdatedKey) boolValue];
}

- (void)cas_setNeedsUpdateStyling {
    objc_setAssociatedObject(self, CASStyleHasBeenUpdatedKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [CASStyler.defaultStyler scheduleUpdateForItem:self];
}

@end
