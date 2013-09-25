//
//  MODNode.m
//  Mod
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODNode.h"

@interface MODNode ()

@property (nonatomic, strong) NSMutableArray *children;

@end

@implementation MODNode

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.children = NSMutableArray.new;

    return self;
}

- (void)addChildNode:(MODNode *)node {
    [self.children addObject:node];
}

@end
