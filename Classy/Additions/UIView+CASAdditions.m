//
//  UIView+CASAdditions.m
//  Classy
//
//  Created by Jonas Budelmann on 30/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "UIView+CASAdditions.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "NSObject+CASSwizzle.h"
#import "CASStyler.h"

@implementation UIView (CASAdditions)

+ (void)load {
    [self cas_swizzleInstanceSelector:@selector(didMoveToWindow)
                      withNewSelector:@selector(cas_didMoveToWindow)];
}

- (void)cas_didMoveToWindow {
    if (!self.cas_styleApplied) {
        [self cas_applyStyle:CASStyler.defaultStyler];
    }

    [self cas_didMoveToWindow];
}

- (void)cas_applyStyle:(CASStyler *)styler {
    [styler styleItem:self];
}

#pragma mark - associated properties

- (id<CASStyleableItem>)cas_parent {
    return self.superview;
}

- (void)setCas_parent:(id<CASStyleableItem>)parent {
}

- (NSString *)cas_styleClass {
    return objc_getAssociatedObject(self, @selector(cas_styleClass));
}

- (void)setCas_styleClass:(NSString *)styleClass {
    if ([self.cas_styleClass isEqual:styleClass]) return;
    objc_setAssociatedObject(self, @selector(cas_styleClass), styleClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (self.window) {
        [self cas_applyStyle:CASStyler.defaultStyler];
    } else {
        self.cas_styleApplied = NO;
    }
}

- (BOOL)cas_styleApplied {
    return [objc_getAssociatedObject(self, @selector(cas_styleApplied)) boolValue];
}

- (void)setCas_styleApplied:(BOOL)styleApplied {
    objc_setAssociatedObject(self, @selector(cas_styleApplied), @(styleApplied), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
