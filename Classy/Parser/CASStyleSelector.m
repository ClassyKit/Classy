//
//  CASStyleSelector.m
//  Classy
//
//  Created by Jonas Budelmann on 29/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASStyleSelector.h"
#import "UIView+CASAdditions.h"
#import "NSString+CASAdditions.h"

@implementation CASStyleSelector

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.shouldSelectSubclasses = NO;
    self.shouldSelectIndirectSuperview = YES;

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CASStyleSelector *newSelector = [[self.class allocWithZone:zone] init];
    if (!newSelector) return nil;

    newSelector.viewClass = self.viewClass;
    newSelector.styleClass = self.styleClass;
    newSelector.shouldSelectSubclasses = self.shouldSelectSubclasses;
    newSelector.shouldSelectIndirectSuperview = self.shouldSelectIndirectSuperview;
    newSelector.arguments = [self.arguments copy];
    newSelector.parentSelector = [self.parentSelector copy];

    return newSelector;
}

#pragma mark - properties

- (CASStyleSelector *)lastSelector {
    return self.parentSelector.lastSelector ?: self;
}

#pragma mark - public

- (NSInteger)precedence {
    NSInteger precedence = 0;
    if (self.viewClass) {
        if (self.isParent) {
            precedence += self.shouldSelectIndirectSuperview ? 2 : 3;
        } else {
            precedence += 4;
        }
        if (self.shouldSelectSubclasses) {
            precedence -= 2;
        }
    }

    if (self.styleClass) {
        if (self.isParent) {
            precedence += self.shouldSelectIndirectSuperview ? 1000 : 2000;
        } else {
            precedence += 3000;
        }
    }

    precedence += self.parentSelector.precedence;
    return precedence;
}

- (BOOL)shouldSelectView:(UIView *)view {
    if (![self shouldSelectSingleView:view]) {
        return NO;
    }

    UIView *ancestorView;

    BOOL traverse = self.shouldSelectIndirectSuperview;
	for (CASStyleSelector *parent = self.parentSelector; parent != nil; parent = parent.parentSelector) {
        ancestorView = [parent firstSelectableAncestorOfView:ancestorView ?: view traverse:traverse];
        if (!ancestorView) return NO;
        traverse = parent.shouldSelectIndirectSuperview;
    }

    return YES;
}

- (NSString *)stringValue {
    NSMutableString *stringValue = NSMutableString.new;
    if (self.parentSelector) {
        [stringValue appendFormat:self.shouldSelectIndirectSuperview ? @"%@ " : @"%@ > ", [self.parentSelector stringValue]];
    }
    if (self.shouldSelectSubclasses) {
        [stringValue appendString:@"^"];
    }
    if (self.viewClass) {
        [stringValue appendString:NSStringFromClass(self.viewClass)];
    }
    if (self.arguments) {
        [stringValue appendString:@"["];
        NSArray *keys = [self.arguments.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            [stringValue appendFormat:@"%@:%@", key, self.arguments[key]];
            if (idx != keys.count - 1) {
                [stringValue appendString:@", "];
            }
        }];
        [stringValue appendString:@"]"];
    }
    if (self.styleClass) {
        [stringValue appendFormat:@".%@", self.styleClass];
    }
    return stringValue;
}

#pragma mark - private

- (UIView *)firstSelectableAncestorOfView:(UIView *)view traverse:(BOOL)traverse {
	for (UIView *ancestor = view.superview; ancestor != nil; ancestor = ancestor.superview) {
        if ([self shouldSelectSingleView:ancestor]) return ancestor;
        if (!traverse) return nil;
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
    if (self.styleClass.length && ![self.styleClass isEqualToString:view.cas_styleClass]) {
        return NO;
    }
    return YES;
}

@end
