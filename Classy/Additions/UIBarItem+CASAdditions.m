//
//  UIBarItem+CASAdditions.m
//  
//
//  Created by Jonas Budelmann on 5/11/13.
//
//

#import "UIBarItem+CASAdditions.h"
#import <objc/runtime.h>
#import "CASStyler.h"

@implementation UIBarItem (CASAdditions)

#pragma mark - CASStyleableItem

- (NSString *)cas_styleClass {
    return objc_getAssociatedObject(self, @selector(cas_styleClass));
}

- (void)setCas_styleClass:(NSString *)styleClass {
    if ([self.cas_styleClass isEqual:styleClass]) return;
    objc_setAssociatedObject(self, @selector(cas_styleClass), styleClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self cas_setNeedsUpdateStyling];
}

- (id<CASStyleableItem>)cas_parent {
    return objc_getAssociatedObject(self, @selector(cas_parent));
}

- (void)setCas_parent:(id<CASStyleableItem>)parent {
    objc_setAssociatedObject(self, @selector(cas_parent), parent, OBJC_ASSOCIATION_ASSIGN);
}

- (id<CASStyleableItem>)cas_alternativeParent {
    return nil;
}

- (void)cas_updateStylingIfNeeded {
    if ([self cas_needsUpdateStyling] && self.cas_parent) {
        [self cas_updateStyling];
    }
}

- (void)cas_updateStyling {
    [CASStyler.defaultStyler styleItem:self];
}

- (BOOL)cas_needsUpdateStyling {
    return [self.cas_parent cas_needsUpdateStyling];
}

- (void)cas_setNeedsUpdateStyling {
    [self.cas_parent cas_setNeedsUpdateStyling];
}

@end
