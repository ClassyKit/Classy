//
//  MODStyleSelector.m
//  Mod
//
//  Created by Jonas Budelmann on 29/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODStyleSelector.h"

@interface MODStyleSelector ()

@property (nonatomic, assign, readwrite) MODStyleSelectorType type;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) MODStyleNode *node;
@property (nonatomic, strong) NSArray *components;

@end

@implementation MODStyleSelector

- (id)initWithName:(NSString *)name node:(MODStyleNode *)node {
    self = [super init];
    if (!self) return nil;

    self.name = [name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!self.name.length) return nil;
    self.node = node;

    self.components = [self.name componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!self.components.count) return nil;

    NSInteger pseudoLocation = [self.components.lastObject rangeOfString:@":"].location;
    NSInteger styleClassLocation = [self.components.lastObject rangeOfString:@"."].location;

    if (pseudoLocation == 0) {
        self.type = MODStyleSelectorTypePseudo;
    } else if (styleClassLocation == 0) {
        self.type = MODStyleSelectorTypeStyleClass;
    } else {
        self.type = MODStyleSelectorTypeViewClass;
        if (pseudoLocation != NSNotFound) {
            self.type = self.type | MODStyleSelectorTypePseudo;
        }
        if (styleClassLocation != NSNotFound) {
            self.type = self.type | MODStyleSelectorTypeStyleClass;
        }
    }

    return self;
}

- (BOOL)shouldSelectView:(UIView *)view {
    return NO;
}

@end
