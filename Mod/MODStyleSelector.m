//
//  MODStyleSelector.m
//  Mod
//
//  Created by Jonas Budelmann on 29/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODStyleSelector.h"
#import "UIView+MODAdditions.h"

@interface MODStyleSelector ()

@property (nonatomic, assign, readwrite) MODStyleSelectorType type;
@property (nonatomic, strong, readwrite) Class viewClass;
@property (nonatomic, strong, readwrite) NSString *styleClass;
@property (nonatomic, strong, readwrite) NSString *pseudo;
@property (nonatomic, strong, readwrite) NSString *string;
@property (nonatomic, strong, readwrite) NSMutableArray *parentSelectors;
@property (nonatomic, assign, readwrite) BOOL shouldSelectSubclasses;
@property (nonatomic, assign, readwrite) BOOL shouldSelectDescendants;
@property (nonatomic, assign, readwrite) NSInteger precedence;
@property (nonatomic, getter = isParent) BOOL parent;

@end

@implementation MODStyleSelector

- (id)initWithString:(NSString *)string {
    self = [super init];
    if (!self) return nil;

    self.precedence = NSNotFound;

    string = [string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!string.length) return nil;
    self.string = string;

    NSArray *stringComponents = [string componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!stringComponents.count) return nil;

    //extract pseudo and class components
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
        self.shouldSelectSubclasses = [mainString characterAtIndex:0] == '^';
        NSInteger classStartIndex = self.shouldSelectSubclasses ? 1 : 0;
        NSInteger classEndIndex = MIN(mainString.length, MIN(pseudoLocation, styleClassLocation));
        NSRange classNameRange = NSMakeRange(classStartIndex, classEndIndex - classStartIndex);
        NSString *className = [mainString substringWithRange:classNameRange];
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
        __block BOOL shouldSelectDescendants = YES;
        [stringComponents enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *stringComponent, NSUInteger idx, BOOL *stop) {
            if (idx != stringComponents.count - 1 && stringComponent.length) {
                if ([stringComponent isEqualToString:@">"]) {
                    shouldSelectDescendants = NO;
                    return;
                }
                MODStyleSelector *selector = [[MODStyleSelector alloc] initWithString:stringComponent];
                selector.parent = YES;
                selector.shouldSelectDescendants = shouldSelectDescendants;
                [self.parentSelectors addObject:selector];
                shouldSelectDescendants = YES;
            }
        }];
    }

    return self;
}

- (NSInteger)precedence {
    if (_precedence == NSNotFound) {
        _precedence = 0;
        if (self.viewClass) {
            if (self.isParent) {
                _precedence += self.shouldSelectDescendants ? 2 : 3;
            } else {
                _precedence += 4;
            }
            if (self.shouldSelectSubclasses) {
                _precedence -= 2;
            }
        }

        if (self.styleClass) {
            if (self.isParent) {
                _precedence += self.shouldSelectDescendants ? 1000 : 2000;
            } else {
                _precedence += 3000;
            }
        }

        if (self.isParent) return _precedence;

        for (MODStyleSelector *parentSelector in self.parentSelectors) {
            _precedence += parentSelector.precedence;
        }
    }
    return _precedence;
}

- (UIView *)firstSelectableAncestorOfView:(UIView *)view {
	for (UIView *ancestor = view.superview; ancestor != nil; ancestor = ancestor.superview) {
        if ([self shouldSelectSingleView:ancestor]) return ancestor;
        if (!self.shouldSelectDescendants) return nil;
	}
	return nil;
}

- (BOOL)shouldSelectSingleView:(UIView *)view {
    if (self.viewClass) {
        if (self.shouldSelectSubclasses) {
            if (![view isKindOfClass:self.viewClass]) return NO;
        } else {
            if (![view isMemberOfClass:self.viewClass]) return NO;
        }
    }
    if (self.styleClass.length && ![self.styleClass isEqualToString:view.mod_styleClass]) {
        return NO;
    }
    return YES;
}

- (BOOL)shouldSelectView:(UIView *)view {
    if (![self shouldSelectSingleView:view]) {
        return NO;
    }

    UIView *ancestorView;
    for (MODStyleSelector *parentSelector in self.parentSelectors) {
        ancestorView = [parentSelector firstSelectableAncestorOfView:ancestorView ?: view];
        if (!ancestorView) return NO;
    }

    return YES;
}

@end
