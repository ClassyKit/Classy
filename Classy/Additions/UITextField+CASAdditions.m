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
