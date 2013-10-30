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
@property (nonatomic, strong, readonly) NSArray *argumentDescriptors;
@property (nonatomic, assign, readonly) SEL setter;

- (id)initWithKey:(NSString *)key argumentDescriptors:(NSArray *)argumentDescriptors;
- (id)initWithKey:(NSString *)key argumentDescriptors:(NSArray *)argumentDescriptors setter:(SEL)setter;

@end
