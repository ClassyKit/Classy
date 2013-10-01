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
@property (nonatomic, strong, readwrite) Class viewClass;
@property (nonatomic, strong, readwrite) NSString *styleClass;
@property (nonatomic, strong, readwrite) NSString *pseudo;
@property (nonatomic, strong, readwrite) NSString *string;
@property (nonatomic, strong, readwrite) NSMutableArray *parentSelectors;
@property (nonatomic, assign, readwrite) BOOL immediateViewClassOnly;
@property (nonatomic, assign, readwrite) BOOL immediateSuperviewOnly;
@property (nonatomic, assign, readwrite) BOOL appleClass;

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

    //extract pseudo and class components
    self.immediateViewClassOnly = YES;
    NSString *mainString = stringComponents.lastObject;
    NSInteger pseudoLocation = [mainString rangeOfString:@":"].location;
    NSInteger styleClassLocation = [mainString rangeOfString:@"."].location;

    //TODO error if more then one occurance of `.` or `:`
    //TODO error if `.` cannot come after `:`
    if (pseudoLocation == 0) {
        self.type = MODStyleSelectorTypePseudo;
    } else if (styleClassLocation == 0) {
        self.type = MODStyleSelectorTypeStyleClass;
    } else {
        self.type = MODStyleSelectorTypeViewClass;
        NSInteger classEndIndex = MIN(mainString.length, MIN(pseudoLocation, styleClassLocation));
        self.immediateViewClassOnly = [mainString characterAtIndex:classEndIndex-1] != '?';
        classEndIndex -= self.immediateViewClassOnly ? 0 : 1;
        NSString *className = [mainString substringToIndex:classEndIndex];
        self.viewClass = NSClassFromString(className);
    }

    if (pseudoLocation != NSNotFound) {
        self.type = self.type | MODStyleSelectorTypePseudo;
        self.pseudo = [mainString substringFromIndex:pseudoLocation+1];
    }
    if (styleClassLocation != NSNotFound) {
        self.type = self.type | MODStyleSelectorTypeStyleClass;
        NSInteger endLocation = MIN(mainString.length, pseudoLocation);
        self.styleClass = [mainString substringWithRange:NSMakeRange(styleClassLocation+1, endLocation - styleClassLocation - 1)];
    }

    //extract selector hierarchy
    if (stringComponents.count > 1) {
        self.parentSelectors = NSMutableArray.new;
        __block BOOL immediateSuperviewOnly = NO;
        [stringComponents enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *stringComponent, NSUInteger idx, BOOL *stop) {
            if (idx != stringComponents.count - 1 && stringComponent.length) {
                if ([stringComponent isEqualToString:@">"]) {
                    immediateSuperviewOnly = YES;
                    return;
                }
                MODStyleSelector *selector = [[MODStyleSelector alloc] initWithString:stringComponent];
                if (immediateSuperviewOnly) {
                    selector.immediateSuperviewOnly = YES;
                    immediateSuperviewOnly = NO;
                }
                [self.parentSelectors addObject:selector];
            }
        }];
    }

    return self;
}

- (NSInteger)precedence {
    return 0;
}

@end
