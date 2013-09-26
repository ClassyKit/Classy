//
//  MODStyleProperty.m
//  Mod
//
//  Created by Jonas Budelmann on 25/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODStyleProperty.h"

@interface MODStyleProperty ()

@property (nonatomic, strong, readwrite) MODToken *nameToken;
@property (nonatomic, strong) NSArray *valueTokens;

@end

@implementation MODStyleProperty

- (id)initWithNameToken:(MODToken *)nameToken valueTokens:(NSArray *)valueTokens {
    self = [super init];
    if (!self) return nil;

    self.nameToken = nameToken;
    self.valueTokens = valueTokens;

    return self;
}

- (BOOL)isValid {
    return self.nameToken.value && self.valueTokens.count;
}

- (NSString *)name {
    return self.nameToken.value;
}

- (NSArray *)values {
    NSMutableArray *values = NSMutableArray.new;
    for (MODToken *valueToken in self.valueTokens) {
        if (valueToken.value) {
            [values addObject:valueToken.value];
        }
    }
    return values;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"name: %@, values: %@", self.nameToken, self.valueTokens];
}

@end
