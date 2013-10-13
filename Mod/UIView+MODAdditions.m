//
//  UIView+MODAdditions.m
//  Mod
//
//  Created by Jonas Budelmann on 30/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "UIView+MODAdditions.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@implementation UIView (MODAdditions)

#pragma mark - associated properties

- (NSString *)mod_styleClass {
    return objc_getAssociatedObject(self, @selector(mod_styleClass));
}

- (void)setMod_styleClass:(NSString *)styleClass {
    objc_setAssociatedObject(self, @selector(mod_styleClass),styleClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - style properties

- (void)setMod_borderColor:(UIColor *)mod_borderColor {
    self.layer.borderColor = mod_borderColor.CGColor;
}

- (UIColor *)mod_borderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setMod_borderWidth:(CGFloat)mod_borderWidth {
    self.layer.borderWidth = mod_borderWidth;
}

- (CGFloat)mod_borderWidth {
    return self.layer.borderWidth;
}

- (void)setMod_cornerRadius:(CGFloat)mod_cornerRadius {
    self.layer.cornerRadius = mod_cornerRadius;
}

- (CGFloat)mod_cornerRadius {
    return self.layer.cornerRadius;
}

@end
