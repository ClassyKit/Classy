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
#import "NSString+CASAdditions.h"
#import "CASStyleClassUtilities.h"

@implementation UIBarItem (CASAdditions)

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
