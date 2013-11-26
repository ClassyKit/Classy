//
//  UIDevice+CASMockDevice.m
//  ClassyTests
//
//  Created by Jonas Budelmann on 26/11/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "UIDevice+CASMockDevice.h"
#import "CASSwizzler.h"

@implementation UIDevice (CASMockDevice)

+ (void)load {
    SwizzleClassMethod(self, @selector(currentDevice), @selector(cas_currentDevice));
}

+ (UIDevice *)cas_currentDevice {
    return [self mockDevice] ?: [self cas_currentDevice];
}

+ (void)setMockDevice:(UIDevice *)mockDevice {
    objc_setAssociatedObject(self, @selector(mockDevice), mockDevice, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (UIDevice *)mockDevice {
    return objc_getAssociatedObject(self, @selector(mockDevice));
}

@end
