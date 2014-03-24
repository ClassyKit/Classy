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
    [self cas_setNeedsUpdateStyling];
    [self.view cas_setNeedsUpdateStylingForSubviews];
}

- (void)cas_addStyleClass:(NSString *)styleClass {
    if (styleClass.length == 0) return;
    if (self.cas_styleClasses == nil) {
        self.cas_styleClasses = [NSSet setWithObject:styleClass];
    }
    else {
        self.cas_styleClasses = [self.cas_styleClasses setByAddingObject:styleClass];
    }
}

- (void)cas_removeStyleClass:(NSString *)styleClass {
    if (self.cas_styleClasses == nil || styleClass.length == 0) return;
    NSMutableSet *styleClasses = [NSMutableSet setWithSet:self.cas_styleClasses];
    [styleClasses removeObject:styleClass];
    self.cas_styleClasses = [styleClasses copy];
}

- (BOOL)cas_hasStyleClass:(NSString *)styleClass {
    return [self.cas_styleClasses containsObject:styleClass];
}

- (id<CASStyleableItem>)cas_parent {
    return self.view.superview;
}

- (id<CASStyleableItem>)cas_alternativeParent {
    return self.parentViewController;
}

- (void)cas_updateStylingIfNeeded {
    if ([self cas_needsUpdateStyling] && self.view.window) {
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
