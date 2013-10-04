//
//  MODParser.m
//  Mod
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODParser.h"
#import "MODLexer.h"
#import "MODStyleNode.h"
#import "MODToken.h"
#import "MODLog.h"
#import "MODStyleProperty.h"
#import "MODStyleSelector.h"

NSString * const MODParseFailingFilePathErrorKey = @"MODParseFailingFilePathErrorKey";
NSInteger const MODParseErrorFileContents = 2;

@interface MODParser ()

@property (nonatomic, strong) MODLexer *lexer;
@property (nonatomic, strong) NSMutableArray *styleSelectors;

@end

@implementation MODParser

+ (NSArray *)stylesFromFilePath:(NSString *)filePath error:(NSError **)error {
    NSError *fileError = nil;
    NSString *contents = [NSString stringWithContentsOfFile:filePath
                                                   encoding:NSUTF8StringEncoding
                                                      error:&fileError];
    if (!contents || fileError) {
        NSMutableDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Could not parse file",
            NSLocalizedFailureReasonErrorKey: @"File does not exist or is empty",
            MODParseFailingFilePathErrorKey : filePath ?: @""
        }.mutableCopy;

        if (fileError) {
            [userInfo setObject:fileError forKey:NSUnderlyingErrorKey];
        }

        if (error) {
            *error = [NSError errorWithDomain:MODParseErrorDomain code:MODParseErrorFileContents userInfo:userInfo];
        }
        
        return nil;
    }

    MODLog(@"Start parsing file \n%@", filePath);
    NSError *parseError = nil;
    NSArray *styles = [self stylesFromString:contents error:&parseError];
    if (parseError) {
        NSMutableDictionary *userInfo = parseError.userInfo.mutableCopy;
        [userInfo addEntriesFromDictionary:@{ MODParseFailingFilePathErrorKey : filePath }];
        if (error) {
            *error = [NSError errorWithDomain:parseError.domain code:parseError.code userInfo:userInfo];
        }
        return nil;
    }

    return styles;
}

+ (NSArray *)stylesFromString:(NSString *)string error:(NSError **)error {
    MODParser *parser = MODParser.new;
    NSError *parseError = nil;
    NSArray *styles = [parser parseString:string error:&parseError];

    if (parseError) {
        if (error) {
            *error = parseError;
        }
        return nil;
    }
    if (!styles.count) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Could not parse string",
            NSLocalizedFailureReasonErrorKey: @"Could not find any styles"
        };
        if (error) {
            *error = [NSError errorWithDomain:MODParseErrorDomain code:MODParseErrorFileContents userInfo:userInfo];
        }
        return nil;
    }
    
    return styles;
}

- (NSArray *)parseString:(NSString *)string error:(NSError **)error {
    self.lexer = [[MODLexer alloc] initWithString:string];
    self.styleSelectors = NSMutableArray.new;

    MODStyleNode *currentNode = nil;
    while (self.peekToken.type != MODTokenTypeEOS) {
        if (self.lexer.error) {
            if (error) {
                *error = self.lexer.error;
            }
            return nil;
        }

        MODStyleNode *styleNode = [self nextStyleNode];
        if (styleNode) {
            currentNode = styleNode;
            [self consumeTokenOfType:MODTokenTypeLeftCurlyBrace];
            [self consumeTokenOfType:MODTokenTypeIndent];
            MODLog(@"(line %d) MODStyleNode %@", self.peekToken.lineNumber, currentNode);
            continue;
        }

        //not a style group therefore must be a property
        MODStyleProperty *styleProperty = [self nextStyleProperty];
        if (styleProperty) {
            if (!currentNode) {
                if (error) {
                    *error = [self.lexer errorWithDescription:@"Invalid style property"
                                                       reason:@"Needs to be within a style node"
                                                         code:MODParseErrorFileContents];
                }
                return nil;
            }
            [currentNode addStyleProperty:styleProperty];
            MODLog(@"(line %d) MODStyleProperty `%@`", self.peekToken.lineNumber, styleProperty);
            continue;
        }

        BOOL closeNode = [self consumeTokensMatching:^BOOL(MODToken *token) {
            return token.type == MODTokenTypeOutdent || token.type == MODTokenTypeRightCurlyBrace;
        }];
        if (closeNode) {
            currentNode = nil;
        }

        BOOL acceptableToken = [self consumeTokensMatching:^BOOL(MODToken *token) {
            return token.isWhitespace || token.type == MODTokenTypeSemiColon;
        }];
        if (!acceptableToken && !closeNode) {
            NSString *description = [NSString stringWithFormat:@"Unexpected token `%@`", self.nextToken];
            if (error) {
                *error = [self.lexer errorWithDescription:description
                                                   reason:@"Token does not belong in current context"
                                                     code:MODParseErrorFileContents];
            }
            return nil;
        }
    }

    return self.styleSelectors;
}

#pragma mark - token helpers

- (MODToken *)peekToken {
    return self.lexer.peekToken;
}

- (MODToken *)nextToken {
    MODToken *token = self.lexer.nextToken;
    return token;
}

- (MODToken *)lookaheadByCount:(NSUInteger)count {
    return [self.lexer lookaheadByCount:count];
}

- (MODToken *)consumeTokenOfType:(MODTokenType)type {
    if (type == self.peekToken.type) {
        //return token and remove from stack
        return self.nextToken;
    }
    return nil;
}

- (MODToken *)consumeTokenWithValue:(id)value {
    if ([self.peekToken valueIsEqualTo:value]) {
        //return token and remove from stack
        return self.nextToken;
    }
    return nil;
}

- (BOOL)consumeTokensMatching:(BOOL(^)(MODToken *token))matchBlock {
    BOOL anyMatches = NO;
    while (matchBlock(self.peekToken)) {
        anyMatches = YES;
        [self nextToken];
    }
    return anyMatches;
}

#pragma mark - nodes

- (MODStyleNode *)nextStyleNode {
    NSInteger i = 1;
    MODToken *token = [self lookaheadByCount:i];
    while (token && token.isPossiblySelector) {
        token = [self lookaheadByCount:++i];
    }

    if (token.type != MODTokenTypeLeftCurlyBrace && token.type != MODTokenTypeIndent) {
        return nil;
    }

    MODStyleNode *node = MODStyleNode.new;
    MODStyleSelector *currentSelector = MODStyleSelector.new;
    currentSelector.node = node;
    BOOL shouldIgnoreWhitespace = NO;
    MODToken *previousToken;
    token = nil;

    while (--i > 0) {
        previousToken = token;
        token = [self nextToken];

        if (token.type == MODTokenTypeCarat) {
            currentSelector.shouldSelectSubclasses = YES;
        } else if (token.type == MODTokenTypeRef) {
            NSString *viewClassName = [token.value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
            //TODO error if viewClass is nil
            currentSelector.viewClass = NSClassFromString(viewClassName);

        } else if (token.type == MODTokenTypeLeftSquareBrace) {
            shouldIgnoreWhitespace = YES;
        } else if (token.type == MODTokenTypeRightSquareBrace) {
            shouldIgnoreWhitespace = NO;
        } else if (token.type == MODTokenTypeSelector) {
            //TODO styleClass
            currentSelector.styleClass = token.value;
        } else if([token valueIsEqualTo:@">"]) {
            if (previousToken.isWhitespace) {
                //already created new child
                currentSelector.parentSelector.shouldSelectDescendants = YES;
            } else {
                //new selector
                currentSelector.shouldSelectDescendants = YES;
                currentSelector.childSelector = MODStyleSelector.new;
                currentSelector = currentSelector.childSelector;
            }
        } else if (token.isWhitespace) {
            if (shouldIgnoreWhitespace) continue;
            //new selector
            currentSelector.childSelector = MODStyleSelector.new;
            currentSelector = currentSelector.childSelector;
            shouldIgnoreWhitespace = YES;
        } else if ([token valueIsEqualTo:@","]) {
            [self.styleSelectors addObject:currentSelector];
            currentSelector = MODStyleSelector.new;
            currentSelector.node = node;
        }
    }
    [self.styleSelectors addObject:currentSelector];

    return node;
}

- (MODStyleProperty *)nextStyleProperty {
    NSInteger i = 1;
    MODToken *nameToken;
    NSMutableArray *valueTokens = NSMutableArray.new;

    MODToken *token = [self lookaheadByCount:i];
    while (token && token.type != MODTokenTypeNewline
           && token.type != MODTokenTypeLeftCurlyBrace
           && token.type != MODTokenTypeRightCurlyBrace
           && token.type != MODTokenTypeOutdent
           && token.type != MODTokenTypeSemiColon
           && token.type != MODTokenTypeEOS) {

        if (token.type == MODTokenTypeSpace
            || token.type == MODTokenTypeIndent
            || [token valueIsEqualTo:@":"]) {
            token = [self lookaheadByCount:++i];
            continue;
        }

        if (!nameToken) {
            nameToken = token;
        } else {
            [valueTokens addObject:token];
        }
        token = [self lookaheadByCount:++i];
    }

    if (nameToken.value && valueTokens.count) {
        //consume tokens
        while (--i > 0) {
            [self nextToken];
        }
        return [[MODStyleProperty alloc] initWithNameToken:nameToken valueTokens:valueTokens];
    }

    return nil;
}

@end
