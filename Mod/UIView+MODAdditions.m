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

#pragma mark - border properties

- (void)setMod_borderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)mod_borderColor {
    if (!self.layer.borderColor) return nil;
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setMod_borderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)mod_borderWidth {
    return self.layer.borderWidth;
}

- (void)setMod_cornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)mod_cornerRadius {
    return self.layer.cornerRadius;
}

#pragma mark - shadow properties

- (void)setMod_shadowColor:(UIColor *)shadowColor {
    self.layer.shadowColor = shadowColor.CGColor;
}

- (UIColor *)mod_shadowColor {
    if (!self.layer.shadowColor) return nil;
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}

- (void)setMod_shadowOffset:(CGSize)shadowOffset {
    self.layer.shadowOffset = shadowOffset;
}

- (CGSize)mod_shadowOffset {
    return self.layer.shadowOffset;
}

- (void)setMod_shadowOpacity:(CGFloat)shadowOpacity {
    self.layer.shadowOpacity = shadowOpacity;
}

- (CGFloat)mod_shadowOpacity {
    return self.layer.shadowOpacity;
}

- (void)setMod_shadowRadius:(CGFloat)shadowRadius {
    self.layer.shadowRadius = shadowRadius;
}

- (CGFloat)mod_shadowRadius {
    return self.layer.shadowRadius;
}

@end
