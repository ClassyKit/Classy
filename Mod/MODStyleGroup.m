//
//  MODStyleGroup.m
//  Mod
//
//  Created by Jonas Budelmann on 25/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODStyleGroup.h"

@interface MODStyleGroup ()

@property (nonatomic, strong) NSMutableArray *selectors;
@property (nonatomic, strong) NSMutableArray *styleProperties;

@end

@implementation MODStyleGroup

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.selectors = NSMutableArray.new;
    self.styleProperties = NSMutableArray.new;

    return self;
}

- (void)addSelector:(NSString *)selector {
    selector = [selector stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (selector.length) {
        [self.selectors addObject:selector];
    }
}

- (void)addStyleProperty:(MODStyleProperty *)styleProperty {
    [self.styleProperties addObject:styleProperty];
}

#pragma mark - debug

- (NSString *)description {
    return [NSString stringWithFormat:@"selectors: %@", self.selectors];
}

@end
