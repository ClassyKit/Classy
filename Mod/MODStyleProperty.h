//
//  MODStyleProperty.h
//  Mod
//
//  Created by Jonas Budelmann on 25/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MODToken.h"

@interface MODStyleProperty : NSObject

/**
 *  Name of the receiver
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  Raw values of the receiver
 */
@property (nonatomic, strong, readonly) NSArray *values;

/**
 *  NSInvocation to apply to appropriate view
 */
@property (nonatomic, strong) NSInvocation *invocation;

- (id)initWithNameToken:(MODToken *)nameToken valueTokens:(NSArray *)valueTokens;

@end
