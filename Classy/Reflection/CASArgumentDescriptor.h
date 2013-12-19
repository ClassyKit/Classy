//
//  CASArgumentDescriptor.h
//  Classy
//
//  Created by Jonas Budelmann on 12/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Supported primitive argument types
 */
typedef NS_ENUM(NSUInteger, CASPrimitiveType) {
    CASPrimitiveTypeNone,
    CASPrimitiveTypeUnsupported,
    CASPrimitiveTypeBOOL,
    CASPrimitiveTypeDouble,
    CASPrimitiveTypeInteger,
    CASPrimitiveTypeCGPoint,
    CASPrimitiveTypeCGSize,
    CASPrimitiveTypeCGRect,
    CASPrimitiveTypeUIEdgeInsets,
    CASPrimitiveTypeUIOffset,
    CASPrimitiveTypeCGColorRef,
};



@interface CASArgumentDescriptor : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) Class argumentClass;
@property (nonatomic, assign, readonly) CASPrimitiveType primitiveType;
@property (nonatomic, strong, readonly) NSDictionary *valuesByName;

+ (instancetype)argWithObjCType:(const char *)type;
+ (instancetype)argWithType:(NSString *)type;
+ (instancetype)argWithClass:(Class)aClass;
+ (instancetype)argWithValuesByName:(NSDictionary *)valuesByName;
+ (instancetype)argWithName:(NSString *)name valuesByName:(NSDictionary *)valuesByName;

@end
