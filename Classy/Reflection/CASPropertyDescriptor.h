//
//  CASPropertyDescriptor.h
//  Classy
//
//  Created by Jonas Budelmann on 12/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CASArgumentDescriptor.h"

@interface CASPropertyDescriptor : NSObject

@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, strong) NSArray *argumentDescriptors;
@property (nonatomic, assign) SEL setter;

- (id)initWithKey:(NSString *)key;

@end
