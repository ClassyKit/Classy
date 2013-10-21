//
//  CASExpressionSolver.m
//  Classy
//
//  Created by Jonas Budelmann on 18/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASExpressionSolver.h"
#import "CASToken.h"

@interface CASExpressionSolver ()

@property (nonatomic, strong) NSMutableArray *tokens;
@property (nonatomic, strong) NSMutableDictionary *tupleByIndex;

@end

@implementation CASExpressionSolver

- (NSArray *)tokensByReducingTokens:(NSArray *)tokens {
    self.tokens = tokens.mutableCopy;
    self.tupleByIndex = NSMutableDictionary.new;
    [self extractTuples];

    NSMutableArray *tokenStack = NSMutableArray.new;
    NSMutableArray *expressionStack = NSMutableArray.new;
    NSMutableDictionary *expressionMap = NSMutableDictionary.new;
    NSMutableDictionary *tupleMap = NSMutableDictionary.new;

    for (CASToken *token in self.tokens) {
        BOOL isPlaceholder = token.value == (id)NSNull.null;
        BOOL isFunctionKeyword = !isPlaceholder && [self.class.acceptableExpressionKeywords containsObject:token.value];
        if (isPlaceholder || isFunctionKeyword || token.isPossiblyExpression ) {
            if (token.isWhitespace && !expressionStack.count) {
                [tokenStack addObject:token];
                continue;
            }
            
            BOOL split = [token valueIsEqualTo:@","] || [self doesToken:token requireSplitForTokens:self.tokens];
            if (split) {
                [tokenStack addObject:NSNull.null];
                expressionMap[@(tokenStack.count-1)] = expressionStack;
                expressionStack = NSMutableArray.new;
            }

            if (isPlaceholder) {
                tupleMap[@(tokenStack.count)] = self.tupleByIndex[@([self.tokens indexOfObject:token])];
            }

            [expressionStack addObject:token];
        } else {
            [tokenStack addObject:token];
        }
    }

    if (expressionStack.count) {
        [tokenStack addObject:NSNull.null];
        expressionMap[@(tokenStack.count-1)] = expressionStack;
    }

    [expressionMap enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSMutableArray *expressionStack, BOOL *stop) {
        NSArray *tuple = tupleMap[key];
        NSInteger index = [key integerValue];
        if (tuple.count) {
            [tokenStack replaceObjectAtIndex:index withObject:[CASToken tokenOfType:CASTokenTypeLeftRoundBrace value:@"("]];
            for (CASToken *tupleToken in tuple) {
                CASToken *token = [self evaluateTokens:expressionStack withPlaceholderToken:tupleToken];
                [tokenStack insertObject:token atIndex:++index];
                if ([tuple indexOfObject:tupleToken] != tuple.count - 1) {
                    [tokenStack insertObject:[CASToken tokenOfType:CASTokenTypeOperator value:@","] atIndex:++index];
                }
            }
            [tokenStack insertObject:[CASToken tokenOfType:CASTokenTypeRightRoundBrace value:@")"] atIndex:++index];
        } else {
            CASToken *token = [self evaluateTokens:expressionStack withPlaceholderToken:nil];
            [tokenStack replaceObjectAtIndex:index withObject:token];
        }
    }];

    return tokenStack;
}

#pragma mark - private

- (void)extractTuples {
    NSArray *tokens = [self.tokens copy];
    NSInteger braceCount = 0, previousBraceCount = 0;
    NSRange tupleRange = NSMakeRange(0, 0);
    NSMutableArray *tuple;

    // TODO this is bit convuluted and fragile.
    // look into extending something like DDMathParser to support tuples

    for (CASToken *token in tokens) {
        if (token.type == CASTokenTypeLeftRoundBrace) {
            braceCount++;
        } else if (token.type == CASTokenTypeRightRoundBrace) {
            braceCount--;
        }

        if (previousBraceCount == 0 && braceCount == 1) {
            // opening tuple brace
            tuple = [NSMutableArray arrayWithObject:NSMutableArray.new];
            tupleRange.location = [self.tokens indexOfObject:token];
        } else if (previousBraceCount > 0 && braceCount == 0) {
            // closing tuple brace
            if (tuple.count > 1) {
                for (NSMutableArray *expressionStack in tuple.copy) {
                    CASToken *token = [self evaluateTokens:expressionStack withPlaceholderToken:nil];
                    [tuple replaceObjectAtIndex:[tuple indexOfObject:expressionStack] withObject:token];
                }
                NSInteger endIndex = [self.tokens indexOfObject:token] + 1;
                tupleRange.length = endIndex - tupleRange.location;
                [self.tokens removeObjectsInRange:tupleRange];
                CASToken *placeholderToken = [CASToken tokenOfType:CASTokenTypeUnit value:NSNull.null];

                [self.tokens insertObject:placeholderToken atIndex:tupleRange.location];
                self.tupleByIndex[@(tupleRange.location)] = tuple;
                tuple = nil;
            }
        } else if (braceCount >= 1) {
            // within tuple

            BOOL split = [token valueIsEqualTo:@","] || [self doesToken:token requireSplitForTokens:tokens];
            if (split) {
                [tuple addObject:NSMutableArray.new];
            }
            if (![token valueIsEqualTo:@","] && !token.isWhitespace) {
                [tuple.lastObject addObject:token];
            }
        }

        previousBraceCount = braceCount;
    }
}

- (BOOL)doesToken:(CASToken *)token requireSplitForTokens:(NSArray *)tokens {
    CASToken *prevNonWhitespaceToken;
    for (NSInteger i = [tokens indexOfObject:token] - 1; i >= 0; i--) {
        if (![tokens[i] isWhitespace]) {
            prevNonWhitespaceToken = tokens[i];
            break;
        }
    }

    return prevNonWhitespaceToken != nil && (
        (prevNonWhitespaceToken.type == CASTokenTypeUnit
         && token.type == CASTokenTypeLeftRoundBrace)
     || (prevNonWhitespaceToken.type == CASTokenTypeRightRoundBrace
         && token.type == CASTokenTypeUnit)
     || (prevNonWhitespaceToken.type == CASTokenTypeUnit
         && token.type == CASTokenTypeUnit));
}

+ (NSSet *)acceptableExpressionKeywords {
    //not a complete list but added ones that seemed useful
    static NSSet * _acceptableExpressionKeywords = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _acceptableExpressionKeywords = [[NSSet alloc] initWithArray:@[
            @"floor", @"abs", @"random", @"ceiling", @"abs",
            @"uppercase", @"lowercase", @"log"
        ]];
    });

    return _acceptableExpressionKeywords;
}

- (CASToken *)evaluateTokens:(NSArray *)tokens withPlaceholderToken:(CASToken *)placeholderToken {
    if (tokens.count == 1) {
        return tokens.lastObject;
    }

    NSMutableArray *values = NSMutableArray.new;
    for (CASToken *token in tokens) {
        if (token.value == (id)NSNull.null) {
            [values addObject:placeholderToken.stringValue];
        } else {
            [values addObject:token.stringValue];
        }
    }

    NSExpression *expression = [NSExpression expressionWithFormat:[values componentsJoinedByString:@""]];
    id value = [expression expressionValueWithObject:nil context:nil];
    return [CASToken tokenOfType:CASTokenTypeUnit value:value];
}

@end
