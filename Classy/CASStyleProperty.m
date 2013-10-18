//
//  CASStyleProperty.m
//  Classy
//
//  Created by Jonas Budelmann on 25/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASStyleProperty.h"
#import "NSString+CASAdditions.h"
#import "CASExpressionSolver.h"

@interface CASStyleProperty ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSArray *values;

@property (nonatomic, strong, readwrite) CASToken *nameToken;
@property (nonatomic, strong, readwrite) NSArray *valueTokens;

@end

@implementation CASStyleProperty

- (id)initWithNameToken:(CASToken *)nameToken valueTokens:(NSArray *)valueTokens {
    self = [super init];
    if (!self) return nil;

    self.nameToken = nameToken;
    self.valueTokens = valueTokens;

    return self;
}

#pragma mark - properties

- (NSString *)name {
    if (!_name) {
        NSArray *components = [self.nameToken.value componentsSeparatedByString:@"-"];
        NSMutableString *camelCasedName = [NSMutableString string];

        for (NSUInteger i = 0; i < components.count; i++) {
            if (i == 0) {
                [camelCasedName appendString:components[i]];
            } else {
                [camelCasedName appendString:[components[i] cas_stringByCapitalizingFirstLetter]];
            }
        }
        _name = camelCasedName;
    }
    return _name;
}

- (NSArray *)values {
    if (!_values) {
        NSMutableArray *values = NSMutableArray.new;
        for (CASToken *valueToken in self.valueTokens) {
            if (valueToken.value) {
                [values addObject:valueToken.value];
            }
        }
        _values = values;
    }
    return _values;
}

#pragma mark - helpers

- (id)valueOfTokenType:(CASTokenType)tokenType {
    for (CASToken *token in self.valueTokens) {
        if (token.type == tokenType) return token.value;
    }
    return nil;
}

- (NSArray *)valuesOfTokenType:(CASTokenType)tokenType {
    NSMutableArray *tokens = NSMutableArray.new;
    for (CASToken *token in self.valueTokens) {
        if (token.type == tokenType) {
            [tokens addObject:token.value];
        }
    }
    return tokens;
}

#pragma - primitive values

- (BOOL)transformValuesToCGSize:(CGSize *)size {
    NSArray *unitTokens = [self valuesOfTokenType:CASTokenTypeUnit];
    if (unitTokens.count == 1) {
        CGFloat value = [unitTokens[0] doubleValue];
        *size = CGSizeMake(value, value);
        return YES;
    }
    if (unitTokens.count == 2) {
        CGFloat value1 = [unitTokens[0] doubleValue];
        CGFloat value2 = [unitTokens[1] doubleValue];
        *size = CGSizeMake(value1, value2);
        return YES;
    }
    return NO;
}

- (BOOL)transformValuesToUIEdgeInsets:(UIEdgeInsets *)insets {
    NSArray *unitTokens = [self valuesOfTokenType:CASTokenTypeUnit];
    if (unitTokens.count == 1) {
        CGFloat value = [unitTokens[0] doubleValue];
        *insets = UIEdgeInsetsMake(value, value, value, value);
        return YES;
    }
    if (unitTokens.count == 2) {
        CGFloat value1 = [unitTokens[0] doubleValue];
        CGFloat value2 = [unitTokens[1] doubleValue];
        *insets = UIEdgeInsetsMake(value2, value1, value2, value1);
        return YES;
    }
    if (unitTokens.count == 4) {
        *insets = UIEdgeInsetsMake([unitTokens[0] doubleValue], [unitTokens[1] doubleValue], [unitTokens[2] doubleValue], [unitTokens[3] doubleValue]);
        return YES;
    }
    return NO;
}

- (void)resolveExpressions {
    BOOL hasOperator = NO;
    for (CASToken *token in self.valueTokens) {
        if (token.type == CASTokenTypeOperator && ![token valueIsEqualTo:@","]) {
            hasOperator = YES;
            break;
        }
    }

    if (!hasOperator) return;

    CASExpressionSolver *solver = CASExpressionSolver.new;
    solver.tokens = [self.valueTokens mutableCopy];

    self.valueTokens = [solver reduceTokens];
    self.values = nil;
}

@end
