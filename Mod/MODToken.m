//
//  MODToken.m
//  Mod
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODToken.h"

@implementation MODToken

- (id)initWithType:(MODTokenType)type value:(NSString *)value {
    self = [super init];
    if (!self) return nil;

    self.type = type;
    self.value = value;

    return self;
}

- (id)initWithType:(MODTokenType)type {
    self = [super init];
    if (!self) return nil;

    self.type = type;

    return self;
}

@end
