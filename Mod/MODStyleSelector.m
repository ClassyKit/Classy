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
@property (nonatomic, assign, readwrite) Class viewClass;
@property (nonatomic, assign, readwrite) NSString *styleClass;
@property (nonatomic, assign, readwrite) NSString *pseudo;

@property (nonatomic, strong, readwrite) NSString *string;
@property (nonatomic, strong, readwrite) NSMutableArray *components;

@end

@implementation MODStyleSelector

- (id)initWithString:(NSString *)string {
    self = [super init];
    if (!self) return nil;

    string = [string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!string.length) return nil;
    self.string = string;

    NSArray *stringComponents = [string componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!stringComponents.count) return nil;

    [self setTypeFromString:stringComponents.lastObject];

    self.components = NSMutableArray.new;
    for (NSInteger i = 0; i < stringComponents.count-1; i++) {
        NSString *stringComponent = stringComponents[i];
        [self.components addObject:[[MODStyleSelector alloc] initWithString:stringComponent]];
    }

    return self;
}

- (void)setTypeFromString:(NSString *)string {
    NSInteger pseudoLocation = [string rangeOfString:@":"].location;
    NSInteger styleClassLocation = [string rangeOfString:@"."].location;

    if (pseudoLocation == 0) {
        self.type = MODStyleSelectorTypePseudo;
    } else if (styleClassLocation == 0) {
        self.type = MODStyleSelectorTypeStyleClass;
    } else {
        self.type = MODStyleSelectorTypeViewClass;
        self.viewClass = NSClassFromString([string substringToIndex:MIN(string.length, MIN(pseudoLocation, styleClassLocation))]);
    }

    if (pseudoLocation != NSNotFound) {
        self.type = self.type | MODStyleSelectorTypePseudo;
        self.pseudo = [string substringFromIndex:pseudoLocation+1];
    }
    if (styleClassLocation != NSNotFound) {
        self.type = self.type | MODStyleSelectorTypeStyleClass;
        NSInteger endLocation = MIN(string.length, pseudoLocation);
        self.styleClass = [string substringWithRange:NSMakeRange(styleClassLocation+1, endLocation - styleClassLocation - 1)];
    }
}

- (BOOL)shouldSelectView:(UIView *)view {
    return NO;
}

@end
