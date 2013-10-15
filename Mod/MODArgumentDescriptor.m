//
//  MODArgumentDescriptor.m
//  Mod
//
//  Created by Jonas Budelmann on 12/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODArgumentDescriptor.h"
#import <UIKit/UIKit.h>

@interface MODArgumentDescriptor ()

@property (nonatomic, strong, readwrite) Class argumentClass;
@property (nonatomic, strong, readwrite) NSString *type;
@property (nonatomic, strong, readwrite) NSDictionary *valuesByName;


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

+ (instancetype)argWithValuesByName:(NSDictionary *)valuesByName {
    MODArgumentDescriptor *descriptor = MODArgumentDescriptor.new;
    descriptor.type = [NSString stringWithUTF8String:@encode(NSInteger)];
    descriptor.valuesByName = valuesByName;
    return descriptor;
}

- (MODPrimitiveType)primitiveType {
    if (!self.type.length) return MODPrimitiveTypeNone;

    // if char type assume it's a BOOL, since chars aren't very useful for styling
    BOOL isBOOL = self.type.length == 1 && [self.type isEqualToString:@"c"];
    if (isBOOL) return MODPrimitiveTypeBOOL;

    // check for integer
    BOOL isInteger = self.type.length == 1 && (
           [self.type isEqualToString:@"i"]   // An int
        || [self.type isEqualToString:@"s"]   // A short
        || [self.type isEqualToString:@"l"]   // A longl is treated as a 32-bit quantity on 64-bit programs.
        || [self.type isEqualToString:@"q"]   // A long long
        || [self.type isEqualToString:@"C"]   // An unsigned char
        || [self.type isEqualToString:@"I"]   // An unsigned int
        || [self.type isEqualToString:@"S"]   // An unsigned short
        || [self.type isEqualToString:@"L"]   // An unsigned long
        || [self.type isEqualToString:@"Q"]); // An unsigned long long
    if (isInteger) return MODPrimitiveTypeInteger;

    // check for double
    BOOL isDouble = self.type.length == 1 && (
           [self.type isEqualToString:@"f"]   // A float
        || [self.type isEqualToString:@"d"]); // A double
    if (isDouble) return MODPrimitiveTypeDouble;

    // check for structs
    if ([self.type hasPrefix:@"{CGSize"]) {
        return MODPrimitiveTypeCGSize;
    } else if ([self.type hasPrefix:@"{CGRect"]) {
        return MODPrimitiveTypeCGSize;
    } else if ([self.type hasPrefix:@"{UIEdgeInsets"]) {
        return MODPrimitiveTypeUIEdgeInsets;
    } else if ([self.type hasPrefix:@"{UIOffset"]) {
        return MODPrimitiveTypeUIOffset;
    }

    return MODPrimitiveTypeUnsupported;
}

@end
