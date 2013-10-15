//
//  UITextField+MODAdditions.m
//  Mod
//
//  Created by Jonas Budelmann on 14/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "UITextField+MODAdditions.h"
#import <objc/runtime.h>
#import "NSObject+MODSwizzle.h"

@implementation UITextField (MODAdditions)

+ (void)load {
    [self mod_swizzleInstanceSelector:@selector(textRectForBounds:)
                      withNewSelector:@selector(mod_textRectForBounds:)];

    [self mod_swizzleInstanceSelector:@selector(editingRectForBounds:)
                      withNewSelector:@selector(mod_editingRectForBounds:)];
}

#pragma mark - font properties

- (void)setMod_fontName:(NSString *)fontName {
    objc_setAssociatedObject(self, @selector(mod_fontName), fontName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.font = [UIFont fontWithName:fontName size:self.mod_fontSize];
}

- (NSString *)mod_fontName {
    return objc_getAssociatedObject(self, @selector(mod_fontName));
}

- (void)setMod_fontSize:(CGFloat)fontSize {
    objc_setAssociatedObject(self, @selector(mod_fontSize), @(fontSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.mod_fontName) {
        self.font = [UIFont fontWithName:self.mod_fontName size:fontSize];
    } else {
        self.font = [UIFont systemFontOfSize:fontSize];
    }
}

- (CGFloat)mod_fontSize {
    return [objc_getAssociatedObject(self, @selector(mod_fontSize)) doubleValue];
}

#pragma mark - text insets

- (void)setMod_textEdgeInsets:(UIEdgeInsets)mod_textEdgeInsets {
    NSValue *value = [NSValue valueWithUIEdgeInsets:mod_textEdgeInsets];
    objc_setAssociatedObject(self, @selector(mod_textEdgeInsets), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)mod_textEdgeInsets {
    return [objc_getAssociatedObject(self, @selector(mod_textEdgeInsets)) UIEdgeInsetsValue];
}

- (CGRect)mod_textRectForBounds:(CGRect)bounds {
    if (UIEdgeInsetsEqualToEdgeInsets(self.mod_textEdgeInsets, UIEdgeInsetsZero)) {
        return [self mod_textRectForBounds:bounds];
    }
    return UIEdgeInsetsInsetRect(bounds, self.mod_textEdgeInsets);
}

- (CGRect)mod_editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
