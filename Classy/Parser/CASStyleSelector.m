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

    newSelector.objectClass = self.objectClass;
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
    Class class = self.objectClass;
    while ((class = class.superclass)) {
        precedence += 1;
    }

    if (self.objectClass) {
        if (self.isParent) {
            precedence += self.shouldSelectIndirectSuperview ? 200 : 300;
        } else {
            precedence += 400;
        }
        if (self.shouldSelectSubclasses) {
            precedence -= 100;
        }
    }

    if (self.styleClass) {
        if (self.isParent) {
            precedence += self.shouldSelectIndirectSuperview ? 10000 : 20000;
        } else {
            precedence += 30000;
        }
    }

    precedence += self.parentSelector.precedence;
    return precedence;
}

- (BOOL)shouldSelectItem:(id<CASStyleableItem>)item {
    if (![self matchesItem:item]) {
        return NO;
    }

    if (self.parentSelector) {
        return [self.parentSelector matchesAncestorsOfItem:item traverse:self.shouldSelectIndirectSuperview];
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
    if (self.objectClass) {
        [stringValue appendString:NSStringFromClass(self.objectClass)];
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

- (BOOL)matchesAncestorsOfItem:(id<CASStyleableItem>)item traverse:(BOOL)traverse {
    id<CASStyleableItem> currentItem = item;

    while (currentItem.cas_parent != nil || currentItem.cas_alternativeParent != nil) {
        id<CASStyleableItem> ancestor;
        if ([self matchesItem:currentItem.cas_parent]) {
            ancestor = currentItem.cas_parent;
        } else if ([self matchesItem:currentItem.cas_alternativeParent]) {
            ancestor = currentItem.cas_alternativeParent;
        }

        if (ancestor) {
            if (!self.parentSelector) return YES;
            BOOL traverse = self.shouldSelectIndirectSuperview;
            if ([self.parentSelector matchesAncestorsOfItem:ancestor traverse:traverse]) return YES;
        }
        if (!traverse) return NO;
        currentItem = currentItem.cas_parent;
    }

    return NO;
}

- (BOOL)matchesItem:(id<CASStyleableItem>)item {
    if (self.objectClass) {
        if (self.shouldSelectSubclasses) {
            if (![item isKindOfClass:self.objectClass]) return NO;
        } else {
            if (![item isMemberOfClass:self.objectClass]) return NO;
        }
    }
    
    if (self.styleClass.length && ![item cas_hasStyleClass:self.styleClass]) {
        return NO;
    }
    return YES;
}

@end
