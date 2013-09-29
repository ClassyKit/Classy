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

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSArray *values;

- (id)initWithNameToken:(MODToken *)nameToken valueTokens:(NSArray *)valueTokens;

@end
