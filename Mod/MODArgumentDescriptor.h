//
//  MODArgumentDescriptor.h
//  Mod
//
//  Created by Jonas Budelmann on 12/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Supported primitive argument types
 */
typedef NS_ENUM(NSUInteger, MODPrimitiveType) {
    MODPrimitiveTypeNone,
    MODPrimitiveTypeUnsupported,
    MODPrimitiveTypeDouble,
    MODPrimitiveTypeInteger,
    MODPrimitiveTypeCGSize,
    MODPrimitiveTypeCGRect,
    MODPrimitiveTypeUIEdgeInsets,
    MODPrimitiveTypeUIOffset
};



@interface MODArgumentDescriptor : NSObject

@property (nonatomic, strong, readonly) Class argumentClass;
@property (nonatomic, assign, readonly) MODPrimitiveType primitiveType;
@property (nonatomic, strong, readonly) NSDictionary *valuesByName;

+ (instancetype)argWithObjCType:(const char *)type;
+ (instancetype)argWithType:(NSString *)type;
+ (instancetype)argWithClass:(Class)class;
+ (instancetype)argWithValuesByName:(NSDictionary *)valuesByName;

@end
