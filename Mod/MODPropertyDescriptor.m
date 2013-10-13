//
//  MODPropertyDescriptor.m
//  Mod
//
//  Created by Jonas Budelmann on 12/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODPropertyDescriptor.h"

@interface MODPropertyDescriptor ()

@property (nonatomic, strong, readwrite) NSString *key;

@end

@implementation MODPropertyDescriptor

- (id)initWithKey:(NSString *)key {
    self = [super init];
    if (!self) return nil;

    self.key = key;

    return self;
}

@end
