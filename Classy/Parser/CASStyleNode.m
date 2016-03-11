//
//  CASStyleGroup.m
//  Classy
//
//  Created by Jonas Budelmann on 25/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASStyleNode.h"

@implementation CASStyleNode {
    NSMutableArray *_styleProperties;
}

@synthesize styleProperties = _styleProperties;

- (id)init {
    self = [super init];
    if (!self) return nil;

    _styleProperties = NSMutableArray.new;

    return self;
}

- (void)addStyleProperty:(CASStyleProperty *)styleProperty {
    [_styleProperties addObject:styleProperty];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (nil != self) {
        self.invocations = nil;
        _styleProperties = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(styleProperties))];
        self.styleSelector = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(styleSelector))];
        self.deviceSelector = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(deviceSelector))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.styleProperties forKey:NSStringFromSelector(@selector(styleProperties))];
    [aCoder encodeObject:self.styleSelector forKey:NSStringFromSelector(@selector(styleSelector))];
    [aCoder encodeObject:self.deviceSelector forKey:NSStringFromSelector(@selector(deviceSelector))];
}

@end
