//
//  UIViewController+CASAdditions.m
//  
//
//  Created by Jonas Budelmann on 17/11/13.
//
//

#import "UIViewController+CASAdditions.h"
#import "NSObject+CASSwizzle.h"
#import "UIView+CASAdditions.h"
#import <objc/runtime.h>
#import "CASStyler.h"

static void *CASStyleHasBeenUpdatedKey = &CASStyleHasBeenUpdatedKey;

@implementation UIViewController (CASAdditions)

+ (void)load {
    [self cas_swizzleInstanceSelector:@selector(setView:)
                      withNewSelector:@selector(cas_setView:)];
}

- (void)cas_setView:(UIView *)view {
    view.cas_alternativeParent = self;

    [self cas_setView:view];
}

#pragma mark - CASStyleableItem

- (NSString *)cas_styleClass {
    return objc_getAssociatedObject(self, @selector(cas_styleClass));
}

- (void)setCas_styleClass:(NSString *)styleClass {
    if ([self.cas_styleClass isEqual:styleClass]) return;
    objc_setAssociatedObject(self, @selector(cas_styleClass), styleClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self cas_setNeedsUpdateStyling];
    [self.view cas_setNeedsUpdateStylingForSubviews];
}

- (id<CASStyleableItem>)cas_parent {
    return self.view.superview;
}

- (id<CASStyleableItem>)cas_alternativeParent {
    return self.parentViewController;
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
