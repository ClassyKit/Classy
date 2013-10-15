//
//  NSObject+MODSwizzle.m
//  Mod
//
//  Created by Jonas Budelmann on 15/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "NSObject+MODSwizzle.h"
#import <objc/runtime.h>

@implementation NSObject (MODSwizzle)

+ (void)mod_swizzleInstanceSelector:(SEL)originalSelector
                    withNewSelector:(SEL)newSelector {
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);

    BOOL methodAdded = class_addMethod([self class],
                                        originalSelector,
                                        method_getImplementation(newMethod),
                                        method_getTypeEncoding(newMethod));

    if (methodAdded) {
        class_replaceMethod([self class],
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@end
