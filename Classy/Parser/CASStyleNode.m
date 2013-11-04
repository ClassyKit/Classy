//
//  CASStyleGroup.m
//  Classy
//
//  Created by Jonas Budelmann on 25/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASStyleNode.h"

@implementation CASStyleNode

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.styleProperties = NSMutableArray.new;

    return self;
}

- (void)addStyleProperty:(CASStyleProperty *)styleProperty {
    [self.styleProperties addObject:styleProperty];
}

@end
