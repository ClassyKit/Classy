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
#import "NSString+CASAdditions.h"
#import "CASStyleClassUtilities.h"


static void *CASStyleHasBeenUpdatedKey = &CASStyleHasBeenUpdatedKey;

@implementation UIViewController (CASAdditions)

+ (void)bootstrapClassy {
    [self cas_swizzleInstanceSelector:@selector(setView:)
                      withNewSelector:@selector(cas_setView:)];
}

- (void)cas_setView:(UIView *)view {
    view.cas_alternativeParent = self;

    [self cas_setView:view];
    [self cas_setNeedsUpdateStyling];
}

#pragma mark - CASStyleableItem

- (NSString *)cas_styleClass {
    return [CASStyleClassUtilities styleClassForItem:self];
}

- (void)setCas_styleClass:(NSString *)styleClass {
    [CASStyleClassUtilities setStyleClass:styleClass forItem:self];
    [self cas_setNeedsUpdateStyling];
    [self.view cas_setNeedsUpdateStylingForSubviews];
}

- (void)cas_addStyleClass:(NSString *)styleClass {
    [CASStyleClassUtilities addStyleClass:styleClass forItem:self];
    [self cas_setNeedsUpdateStyling];
    [self.view cas_setNeedsUpdateStylingForSubviews];
}

- (void)cas_removeStyleClass:(NSString *)styleClass {
    [CASStyleClassUtilities removeStyleClass:styleClass forItem:self];
    [self cas_setNeedsUpdateStyling];
    [self.view cas_setNeedsUpdateStylingForSubviews];
}

- (BOOL)cas_hasStyleClass:(NSString *)styleClass {
    return [CASStyleClassUtilities item:self hasStyleClass:styleClass];
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
    return ![objc_getAssociatedObject(self, CASStyleHasBeenUpdatedKey) boolValue];
}

- (void)cas_setNeedsUpdateStyling {
    objc_setAssociatedObject(self, CASStyleHasBeenUpdatedKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [CASStyler.defaultStyler scheduleUpdateForItem:self];
}

@end
