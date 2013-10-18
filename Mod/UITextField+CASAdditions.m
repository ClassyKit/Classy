//
//  UITextField+CASAdditions.m
//  Classy
//
//  Created by Jonas Budelmann on 14/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "UITextField+CASAdditions.h"
#import <objc/runtime.h>
#import "NSObject+CASSwizzle.h"

@implementation UITextField (CASAdditions)

+ (void)load {
    [self cas_swizzleInstanceSelector:@selector(textRectForBounds:)
                      withNewSelector:@selector(cas_textRectForBounds:)];

    [self cas_swizzleInstanceSelector:@selector(editingRectForBounds:)
                      withNewSelector:@selector(cas_editingRectForBounds:)];
}

#pragma mark - font properties

- (void)setCas_fontName:(NSString *)fontName {
    objc_setAssociatedObject(self, @selector(cas_fontName), fontName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.font = [UIFont fontWithName:fontName size:self.cas_fontSize];
}

- (NSString *)cas_fontName {
    return objc_getAssociatedObject(self, @selector(cas_fontName));
}

- (void)setCas_fontSize:(CGFloat)fontSize {
    objc_setAssociatedObject(self, @selector(cas_fontSize), @(fontSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.cas_fontName) {
        self.font = [UIFont fontWithName:self.cas_fontName size:fontSize];
    } else {
        self.font = [UIFont systemFontOfSize:fontSize];
    }
}

- (CGFloat)cas_fontSize {
    return [objc_getAssociatedObject(self, @selector(cas_fontSize)) doubleValue];
}

#pragma mark - text insets

- (void)setCas_textEdgeInsets:(UIEdgeInsets)cas_textEdgeInsets {
    NSValue *value = [NSValue valueWithUIEdgeInsets:cas_textEdgeInsets];
    objc_setAssociatedObject(self, @selector(cas_textEdgeInsets), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)cas_textEdgeInsets {
    return [objc_getAssociatedObject(self, @selector(cas_textEdgeInsets)) UIEdgeInsetsValue];
}

- (CGRect)cas_textRectForBounds:(CGRect)bounds {
    if (UIEdgeInsetsEqualToEdgeInsets(self.cas_textEdgeInsets, UIEdgeInsetsZero)) {
        return [self cas_textRectForBounds:bounds];
    }
    return UIEdgeInsetsInsetRect(bounds, self.cas_textEdgeInsets);
}

- (CGRect)cas_editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
