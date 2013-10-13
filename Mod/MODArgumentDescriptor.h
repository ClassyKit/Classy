//
//  MODArgumentDescriptor.h
//  Mod
//
//  Created by Jonas Budelmann on 12/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MODArgumentDescriptor : NSObject

@property (nonatomic, strong) NSString *type;

+ (instancetype)argWithObjCType:(const char *)type;
+ (instancetype)argWithClass:(Class)class;
+ (instancetype)argWithName:(NSString *)name valuesByName:(NSDictionary *)valuesByName;

@end
