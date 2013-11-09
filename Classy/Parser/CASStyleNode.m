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

@end
