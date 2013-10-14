//
//  UITextField+MODAdditions.m
//  Mod
//
//  Created by Jonas Budelmann on 14/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "UITextField+MODAdditions.h"
#import <objc/runtime.h>

@implementation UITextField (MODAdditions)

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

@end
