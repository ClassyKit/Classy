//
//  UIView+MODAdditions.m
//  Mod
//
//  Created by Jonas Budelmann on 30/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "UIView+MODAdditions.h"
#import <objc/runtime.h>

@implementation UIView (MODAdditions)

#pragma mark - associated properties

- (NSString *)mod_styleClass {
    return objc_getAssociatedObject(self, @selector(mod_styleClass));
}

- (void)setMod_styleClass:(NSString *)styleClass {
    objc_setAssociatedObject(self, @selector(mod_styleClass),styleClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
