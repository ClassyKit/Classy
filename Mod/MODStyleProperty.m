//
//  MODStyleProperty.m
//  Mod
//
//  Created by Jonas Budelmann on 25/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODStyleProperty.h"

@interface MODStyleProperty ()

@property (nonatomic, strong, readwrite) MODToken *name;
@property (nonatomic, strong) NSArray *values;

@end

@implementation MODStyleProperty

- (id)initWithName:(MODToken *)name values:(NSArray *)values {
    self = [super init];
    if (!self) return nil;

    self.name = name;
    self.values = values;

    return self;
}

- (BOOL)isValid {
    return self.name.value && self.values.count;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"name: %@, values: %@", self.name, self.values];
}

@end
