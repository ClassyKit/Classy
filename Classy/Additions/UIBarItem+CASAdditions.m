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

@implementation UIBarItem (CASAdditions)

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
}

- (void) cas_addStyleClass:(NSString *)styleClass {
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
