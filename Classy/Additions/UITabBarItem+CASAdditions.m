//
//  UITabBarItem+CASAdditions.m
//  
//
//  Created by Jonas Budelmann on 1/11/13.
//
//

#import "UITabBarItem+CASAdditions.h"
#import <objc/runtime.h>
#import "CASStyler.h"

@implementation UITabBarItem (CASAdditions)

- (void)cas_applyStyle:(CASStyler *)styler {
    [styler styleItem:self];
}

#pragma mark - associated properties
//TODO move to macro?

- (id<CASStyleableItem>)cas_parent {
    return objc_getAssociatedObject(self, @selector(cas_parent));
}

- (void)setCas_parent:(id<CASStyleableItem>)parent {
    objc_setAssociatedObject(self, @selector(cas_parent), parent, OBJC_ASSOCIATION_ASSIGN);
}

- (NSString *)cas_styleClass {
    return objc_getAssociatedObject(self, @selector(cas_styleClass));
}

- (void)setCas_styleClass:(NSString *)styleClass {
    objc_setAssociatedObject(self, @selector(cas_styleClass), styleClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)cas_styleApplied {
    return [objc_getAssociatedObject(self, @selector(cas_styleApplied)) boolValue];
}

- (void)setCas_styleApplied:(BOOL)styleApplied {
    objc_setAssociatedObject(self, @selector(cas_styleApplied), @(styleApplied), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
