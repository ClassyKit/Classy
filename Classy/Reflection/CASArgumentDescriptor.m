//
//  CASArgumentDescriptor.m
//  Classy
//
//  Created by Jonas Budelmann on 12/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASArgumentDescriptor.h"
#import <UIKit/UIKit.h>

@interface CASArgumentDescriptor ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) Class argumentClass;
@property (nonatomic, strong, readwrite) NSString *type;
@property (nonatomic, strong, readwrite) NSDictionary *valuesByName;

@end

@implementation CASArgumentDescriptor

+ (instancetype)argWithObjCType:(const char *)type {
    CASArgumentDescriptor *descriptor = CASArgumentDescriptor.new;
    descriptor.type = [NSString stringWithUTF8String:type];
    return descriptor;
}

+ (instancetype)argWithType:(NSString *)type {
    CASArgumentDescriptor *descriptor = CASArgumentDescriptor.new;
    descriptor.type = type;
    return descriptor;
}

+ (instancetype)argWithClass:(Class)aClass {
    CASArgumentDescriptor *descriptor = CASArgumentDescriptor.new;
    descriptor.argumentClass = aClass;
    return descriptor;
}

+ (instancetype)argWithValuesByName:(NSDictionary *)valuesByName {
    CASArgumentDescriptor *descriptor = CASArgumentDescriptor.new;
    descriptor.type = [NSString stringWithUTF8String:@encode(NSInteger)];
    descriptor.valuesByName = valuesByName;
    return descriptor;
}

+ (instancetype)argWithName:(NSString *)name valuesByName:(NSDictionary *)valuesByName {
    CASArgumentDescriptor *descriptor = [self argWithValuesByName:valuesByName];
    descriptor.name = name;
    return descriptor;
}

- (CASPrimitiveType)primitiveType {
    if (!self.type.length) return CASPrimitiveTypeNone;

    // if char type assume it's a BOOL, since chars aren't very useful for styling
    BOOL isBOOL = self.type.length == 1 && ([self.type isEqualToString:@"c"] || [self.type isEqualToString:@"B"]);
    if (isBOOL) return CASPrimitiveTypeBOOL;

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
    if (isInteger) return CASPrimitiveTypeInteger;

    // check for double
    BOOL isDouble = self.type.length == 1 && (
           [self.type isEqualToString:@"f"]   // A float
        || [self.type isEqualToString:@"d"]); // A double
    if (isDouble) return CASPrimitiveTypeDouble;

    // check for structs
    if ([self.type hasPrefix:@"{CGSize"]) {
        return CASPrimitiveTypeCGSize;
    } else if ([self.type hasPrefix:@"{CGPoint"]) {
        return CASPrimitiveTypeCGPoint;
    } else if ([self.type hasPrefix:@"{CGRect"]) {
        return CASPrimitiveTypeCGRect;
    } else if ([self.type hasPrefix:@"{UIEdgeInsets"]) {
        return CASPrimitiveTypeUIEdgeInsets;
    } else if ([self.type hasPrefix:@"{UIOffset"]) {
        return CASPrimitiveTypeUIOffset;
    } else if ([self.type hasPrefix:@"^{CGColor"]) {
        return CASPrimitiveTypeCGColorRef;
    }

    return CASPrimitiveTypeUnsupported;
}

@end
