//
//  MODArgumentDescriptor.m
//  Mod
//
//  Created by Jonas Budelmann on 12/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODArgumentDescriptor.h"

@interface MODArgumentDescriptor ()

@property (nonatomic, strong, readwrite) Class argumentClass;
@property (nonatomic, strong, readwrite) NSString *type;

@end

@implementation MODArgumentDescriptor

+ (instancetype)argWithObjCType:(const char *)type {
    MODArgumentDescriptor *descriptor = MODArgumentDescriptor.new;
    descriptor.type = [NSString stringWithUTF8String:type];
    return descriptor;
}

+ (instancetype)argWithType:(NSString *)type {
    MODArgumentDescriptor *descriptor = MODArgumentDescriptor.new;
    descriptor.type = type;
    return descriptor;
}

+ (instancetype)argWithClass:(Class)class {
    MODArgumentDescriptor *descriptor = MODArgumentDescriptor.new;
    descriptor.argumentClass = class;
    return descriptor;
}

+ (instancetype)argWithName:(NSString *)name valuesByName:(NSDictionary *)valuesByName {
    //TODO
    return nil;
}

@end
