//
//  MODStyleGroup.m
//  Mod
//
//  Created by Jonas Budelmann on 25/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODStyleNode.h"

@interface MODStyleNode ()

@property (nonatomic, strong) NSMutableArray *styleProperties;

@end

@implementation MODStyleNode

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.styleProperties = NSMutableArray.new;

    return self;
}

- (void)addStyleProperty:(MODStyleProperty *)styleProperty {
    [self.styleProperties addObject:styleProperty];
}

@end
