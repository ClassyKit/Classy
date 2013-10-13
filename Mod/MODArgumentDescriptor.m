//
//  MODArgumentDescriptor.m
//  Mod
//
//  Created by Jonas Budelmann on 12/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODArgumentDescriptor.h"

@implementation MODArgumentDescriptor

+ (instancetype)argWithObjCType:(const char *)type {
    MODArgumentDescriptor *descriptor = MODArgumentDescriptor.new;
    descriptor.type = [NSString stringWithUTF8String:type];
    return descriptor;
}

+ (instancetype)argWithClass:(Class)class {
    //TODO
    return nil;
}

+ (instancetype)argWithName:(NSString *)name valuesByName:(NSDictionary *)valuesByName {
    //TODO
    return nil;
}

@end
