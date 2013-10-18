//
//  CASPropertyDescriptor.m
//  Classy
//
//  Created by Jonas Budelmann on 12/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASPropertyDescriptor.h"

@interface CASPropertyDescriptor ()

@property (nonatomic, strong, readwrite) NSString *key;

@end

@implementation CASPropertyDescriptor

- (id)initWithKey:(NSString *)key {
    self = [super init];
    if (!self) return nil;

    self.key = key;

    return self;
}

@end
