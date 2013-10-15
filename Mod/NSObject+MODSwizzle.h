//
//  NSObject+MODSwizzle.h
//  Mod
//
//  Created by Jonas Budelmann on 15/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MODSwizzle)

+ (void)mod_swizzleInstanceSelector:(SEL)originalSelector
                    withNewSelector:(SEL)newSelector;

@end
