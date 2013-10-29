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
    newSelector.shouldConcatToParent = self.shouldConcatToParent;
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
    if (![self matchesView:view]) {
        return NO;
    }

    if (self.parentSelector) {
        return [self.parentSelector matchesAncestorsOfView:view traverse:self.shouldSelectIndirectSuperview];
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

- (BOOL)matchesAncestorsOfView:(UIView *)view traverse:(BOOL)traverse {
    for (UIView *ancestor = view.superview; ancestor != nil; ancestor = ancestor.superview) {
        BOOL ancestorMatch = [self matchesView:ancestor];
        if (ancestorMatch) {
            if (!self.parentSelector) return YES;
            BOOL traverse = self.shouldSelectIndirectSuperview;
            if ([self.parentSelector matchesAncestorsOfView:ancestor traverse:traverse]) return YES;
        }
        if (!traverse) return NO;
    }
    return NO;
}

- (BOOL)matchesView:(UIView *)view {
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
