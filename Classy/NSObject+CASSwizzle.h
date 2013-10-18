//
//  NSObject+CASSwizzle.h
//  Classy
//
//  Created by Jonas Budelmann on 15/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (CASSwizzle)

+ (void)cas_swizzleInstanceSelector:(SEL)originalSelector
                    withNewSelector:(SEL)newSelector;

@end
