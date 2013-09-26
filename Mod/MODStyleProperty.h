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

@property (nonatomic, strong, readonly) MODToken *name;

- (id)initWithName:(MODToken *)name values:(NSArray *)values;
- (BOOL)isValid;

@end
