//
//  MODStyleProperty.m
//  Mod
//
//  Created by Jonas Budelmann on 25/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODStyleProperty.h"
#import "NSString+MODAdditions.h"

@interface MODStyleProperty ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSArray *values;

@property (nonatomic, strong, readwrite) MODToken *nameToken;
@property (nonatomic, strong, readwrite) NSArray *valueTokens;

@end

@implementation MODStyleProperty

- (id)initWithNameToken:(MODToken *)nameToken valueTokens:(NSArray *)valueTokens {
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
                [camelCasedName appendString:[components[i] mod_stringByCapitalizingFirstLetter]];
            }
        }
        _name = camelCasedName;
    }
    return _name;
}

- (NSArray *)values {
    if (!_values) {
        NSMutableArray *values = NSMutableArray.new;
        for (MODToken *valueToken in self.valueTokens) {
            if (valueToken.value) {
                [values addObject:valueToken.value];
            }
        }
        _values = values;
    }
    return _values;
}

#pragma mark - helpers

- (id)valueOfTokenType:(MODTokenType)tokenType {
    for (MODToken *token in self.valueTokens) {
        if (token.type == tokenType) return token.value;
    }
    return nil;
}

- (NSArray *)valuesOfTokenType:(MODTokenType)tokenType {
    NSMutableArray *tokens = NSMutableArray.new;
    for (MODToken *token in self.valueTokens) {
        if (token.type == tokenType) {
            [tokens addObject:token.value];
        }
    }
    return tokens;
}

#pragma - primitive values

- (BOOL)transformValuesToCGSize:(CGSize *)size {
    NSArray *unitTokens = [self valuesOfTokenType:MODTokenTypeUnit];
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
    NSArray *unitTokens = [self valuesOfTokenType:MODTokenTypeUnit];
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
    for (MODToken *token in self.valueTokens) {
        if (token.type == MODTokenTypeOperator && ![token valueIsEqualTo:@","]) {
            hasOperator = YES;
            break;
        }
    }

    if (!hasOperator) return;

    //TODO refactor, this is fragile and convuluted.
    NSInteger braceCounter = 0;
    BOOL needsCloseTuple;
    NSMutableArray *tokenStack = NSMutableArray.new;
    NSMutableArray *expressionStack = NSMutableArray.new;
    NSMutableDictionary *tupleMap = NSMutableDictionary.new;

    NSArray *functionKeywords = @[@"floor"];
    MODToken *prevNonWhitespaceToken;

    for (MODToken *token in self.valueTokens) {
        BOOL isFunctionKeyword = [functionKeywords containsObject:token.value];
        if (token.isPossiblyExpression || isFunctionKeyword) {
            if (token.isWhitespace && !expressionStack.count) {
                [tokenStack addObject:token];
                continue;
            }

            BOOL breakToken = prevNonWhitespaceToken != nil && (
                   (prevNonWhitespaceToken.type == MODTokenTypeUnit
                    && token.type == MODTokenTypeLeftRoundBrace)
                || (prevNonWhitespaceToken.type == MODTokenTypeRightRoundBrace
                    && token.type == MODTokenTypeUnit)
                || (prevNonWhitespaceToken.type == MODTokenTypeUnit
                    && token.type == MODTokenTypeUnit));

            BOOL split = [token valueIsEqualTo:@","] || breakToken;
            if (split) {
                if (braceCounter > 0) {
                    if (!tupleMap.count) {
                        needsCloseTuple = YES;
                        [tokenStack addObject:[MODToken tokenOfType:MODTokenTypeLeftRoundBrace value:@"("]];
                    }

                    [tokenStack addObject:NSNull.null];
                    [expressionStack addObject:[MODToken tokenOfType:MODTokenTypeRightRoundBrace value:@")"]];
                    tupleMap[@(tokenStack.count-1)] = expressionStack;

                    [tokenStack addObject:[MODToken tokenOfType:MODTokenTypeOperator value:@","]];
                    expressionStack = NSMutableArray.new;

                    if (![token valueIsEqualTo:@","]) {
                        [expressionStack addObject:token];
                    };
                } else if (braceCounter == 0) {
                    MODToken *token = [self reduceTokens:expressionStack];
                    [tokenStack addObject:token];
                    expressionStack = NSMutableArray.new;
                }
                prevNonWhitespaceToken= nil;
            } else {
                if (braceCounter == 0 && tupleMap.count) {
                    if (needsCloseTuple) {

                        [tokenStack addObject:NSNull.null];
                        [expressionStack addObject:[MODToken tokenOfType:MODTokenTypeRightRoundBrace value:@")"]];
                        tupleMap[@(tokenStack.count-1)] = expressionStack;
                        expressionStack = NSMutableArray.new;

                        [tokenStack addObject:[MODToken tokenOfType:MODTokenTypeRightRoundBrace value:@")"]];
                    }

                    for (NSMutableArray *expressionStack in tupleMap.allValues) {
                        if (needsCloseTuple) {
                            [self balanceRoundBraces:expressionStack];
                        }
                        [expressionStack addObject:token];
                    }
                    needsCloseTuple = NO;
                } else {
                    [expressionStack addObject:token];
                }
            }

            if (token.type == MODTokenTypeLeftRoundBrace) {
                braceCounter++;
            } else if (token.type == MODTokenTypeRightRoundBrace) {
                braceCounter--;
            }
            
            if (!token.isWhitespace) {
                prevNonWhitespaceToken = token;
            }
        } else {
            [tokenStack addObject:token];
        }
    }

    [tupleMap enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSMutableArray *expressionStack, BOOL *stop) {
        MODToken *token = [self reduceTokens:expressionStack];
        [tokenStack replaceObjectAtIndex:[key integerValue] withObject:token];
        [expressionStack removeAllObjects];
    }];

    if (expressionStack.count) {
        MODToken *token = [self reduceTokens:expressionStack];
        [tokenStack addObject:token];
    }
    self.valueTokens = tokenStack;
    self.values = nil;
}

- (void)balanceRoundBraces:(NSMutableArray *)tokens {
    NSInteger leftIndex = 0;
    while (leftIndex < tokens.count / 2) {
        NSInteger rightIndex = tokens.count - leftIndex - 1;
        MODToken *leftToken = tokens[leftIndex];
        MODToken *rightToken = tokens[rightIndex];
        BOOL hasRightBrace = rightToken.type == MODTokenTypeRightRoundBrace;
        BOOL hasLeftBrace = leftToken.type == MODTokenTypeLeftRoundBrace;

        if (!hasRightBrace && !hasLeftBrace) {
            return;
        }
        if (hasRightBrace && !hasLeftBrace) {
            [tokens insertObject:[MODToken tokenOfType:MODTokenTypeLeftRoundBrace value:@"("] atIndex:leftIndex];
        }
        if (hasLeftBrace && !hasRightBrace) {
            [tokens insertObject:[MODToken tokenOfType:MODTokenTypeRightRoundBrace value:@")"] atIndex:rightIndex];
        }

        leftIndex++;
    }
}

- (MODToken *)reduceTokens:(NSArray *)tokens {
    if (tokens.count == 1) {
        return tokens.lastObject;
    }

    NSMutableArray *values = NSMutableArray.new;
    for (MODToken *token in tokens) {
        [values addObject:token.stringValue];
    }

    NSExpression *expression = [NSExpression expressionWithFormat:[values componentsJoinedByString:@""]];
    id value = [expression expressionValueWithObject:nil context:nil];
    return [MODToken tokenOfType:MODTokenTypeUnit value:value];
}

@end
