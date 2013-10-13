//
//  MODPropertyDescriptor.h
//  Mod
//
//  Created by Jonas Budelmann on 12/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MODArgumentDescriptor.h"

@interface MODPropertyDescriptor : NSObject

@property (nonatomic, strong, readonly) NSInvocation *invocation;
@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, strong) NSArray *argumentDescriptors;

- (id)initWithKey:(NSString *)key;

@end
