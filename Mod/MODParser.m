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
@property (nonatomic, strong) NSMutableDictionary *styleVars;

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
    self.styleVars = NSMutableDictionary.new;

    NSArray *currentNodes = nil;
    while (self.peekToken.type != MODTokenTypeEOS) {
        if (self.lexer.error) {
            if (error) {
                *error = self.lexer.error;
            }
            return nil;
        }

        MODStyleProperty *styleVar = [self nextStyleVar];
        if (styleVar) {
            if (currentNodes.count) {
                //TODO error can't have vars inside styleNOdes
            }
            self.styleVars[styleVar.nameToken.value] = styleVar;
            [self consumeTokensMatching:^BOOL(MODToken *token) {
                return token.isWhitespace || token.type == MODTokenTypeSemiColon;
            }];
            continue;
        }

        NSArray *styleNodes = [self nextStyleNodes];
        if (styleNodes.count) {
            currentNodes = styleNodes;
            [self consumeTokenOfType:MODTokenTypeLeftCurlyBrace];
            [self consumeTokenOfType:MODTokenTypeIndent];
            continue;
        }

        // not a style group therefore must be a property
        MODStyleProperty *styleProperty = [self nextStyleProperty];
        if (styleProperty) {
            if (!currentNodes.count) {
                if (error) {
                    *error = [self.lexer errorWithDescription:@"Invalid style property"
                                                       reason:@"Needs to be within a style node"
                                                         code:MODParseErrorFileContents];
                }
                return nil;
            }
            for (MODStyleNode *node in currentNodes) {
                [node addStyleProperty:styleProperty];
            }
            continue;
        }

        BOOL closeNode = [self consumeTokensMatching:^BOOL(MODToken *token) {
            return token.type == MODTokenTypeOutdent || token.type == MODTokenTypeRightCurlyBrace;
        }];
        if (closeNode) {
            currentNodes = nil;
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
        // return token and remove from stack
        return self.nextToken;
    }
    return nil;
}

- (MODToken *)consumeTokenWithValue:(id)value {
    if ([self.peekToken valueIsEqualTo:value]) {
        // return token and remove from stack
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

- (MODStyleProperty *)nextStyleVar {
    // variable if following seq: MODTokenTypeRef, `=`, any token until newline
    NSInteger i = 1;
    MODToken *token = [self lookaheadByCount:i];
    BOOL hasEqualsSign = NO;
    MODToken *refToken;

    while (token && token.isPossiblyVar && !(hasEqualsSign && refToken)) {
        if (token.type == MODTokenTypeRef) {
            refToken = token;
        }
        if (refToken && [token valueIsEqualTo:@"="]) {
            hasEqualsSign = YES;
        }
        token = [self lookaheadByCount:++i];
    }

    if ([refToken.value hasPrefix:@"@"]) {
        //TODO error `@` is reserved for property lookup
    }

    if (hasEqualsSign && refToken) {
        // consume LHS of var
        while (--i >= 0) {
            [self nextToken];
        }

        // collect value tokens
        NSMutableArray *valueTokens = NSMutableArray.new;
        while (token.type != MODTokenTypeNewline && token.type != MODTokenTypeSemiColon) {
            [valueTokens addObject:token];
            token = [self nextToken];
        }
        return [[MODStyleProperty alloc] initWithNameToken:refToken valueTokens:valueTokens];
    }
    return nil;
}

- (NSArray *)nextStyleNodes {
    NSInteger i = 1;
    MODToken *token = [self lookaheadByCount:i];
    while (token && token.isPossiblySelector) {
        token = [self lookaheadByCount:++i];
    }

    if (token.type != MODTokenTypeLeftCurlyBrace && token.type != MODTokenTypeIndent) {
        return nil;
    }

    NSMutableArray *styleNodes = NSMutableArray.new;
    MODStyleSelector *styleSelector;
    MODToken *previousToken, *argNameToken, *argValueToken;
    token = nil;
    BOOL shouldSelectSubclasses = NO;
    BOOL shouldSelectDescendants = YES;
    BOOL argumentListMode = NO;

    while (--i > 0) {
        previousToken = token;
        token = [self nextToken];

        if (argumentListMode) {
            // TODO refactor
            if (token.type == MODTokenTypeRightSquareBrace) {
                argumentListMode = NO;
            } else if (token.type == MODTokenTypeSelector || token.type == MODTokenTypeRef) {
                if (!argNameToken) {
                    argNameToken = token;
                } else if (!argValueToken) {
                    argValueToken = token;
                }

                if (argNameToken && argValueToken) {
                    [styleSelector setArgumentValue:argValueToken forName:argNameToken];
                    argValueToken = nil;
                    argNameToken = nil;
                }
            }
            continue;
        }

        if (token.type == MODTokenTypeCarat) {
            shouldSelectSubclasses = YES;
        } else if (token.type == MODTokenTypeRef || token.type == MODTokenTypeSelector) {
            NSString *tokenValue = [token.value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];

            BOOL shouldSpawn = ![tokenValue hasPrefix:@"."]
                                || styleSelector == nil
                                || previousToken.isWhitespace
                                || [previousToken valueIsEqualTo:@">"];

            if (shouldSpawn) {
                if (styleSelector) {
                    MODStyleSelector *childSelector = MODStyleSelector.new;
                    styleSelector.shouldSelectDescendants = shouldSelectDescendants;
                    styleSelector.childSelector = childSelector;

                    styleSelector = childSelector;
                } else {
                    styleSelector = MODStyleSelector.new;
                }
            }

            styleSelector.shouldSelectSubclasses = shouldSelectSubclasses;
            
            // TODO error if viewClass is nil

            if ([tokenValue hasPrefix:@"."]) {
                styleSelector.styleClass = [tokenValue substringFromIndex:1];
            } else {
                styleSelector.viewClass = NSClassFromString(tokenValue);
            }

            // reset state
            shouldSelectSubclasses = NO;
            shouldSelectDescendants = YES;
        } else if (token.type == MODTokenTypeLeftSquareBrace) {
            argumentListMode = YES;
        } else if([token valueIsEqualTo:@">"]) {
            shouldSelectDescendants = NO;
        } else if ([token valueIsEqualTo:@","]) {
            if (styleSelector) {
                [styleNodes addObject:MODStyleNode.new];
                styleSelector.node = styleNodes.lastObject;
                [self.styleSelectors addObject:styleSelector];
            }
            styleSelector = nil;
        }
    }
    if (styleSelector) {
        [styleNodes addObject:MODStyleNode.new];
        styleSelector.node = styleNodes.lastObject;
        [self.styleSelectors addObject:styleSelector];
    }
    
    return styleNodes;
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
            if (token.type == MODTokenTypeRef) {
                MODStyleProperty *styleVar = self.styleVars[token.value];
                if (styleVar) {
                    [valueTokens addObjectsFromArray:styleVar.valueTokens];
                } else {
                    [valueTokens addObject:token];
                }
            } else {
                [valueTokens addObject:token];
            }
        }
        token = [self lookaheadByCount:++i];
    }

    if (nameToken.value && valueTokens.count) {
        // consume tokens
        while (--i > 0) {
            [self nextToken];
        }
        return [[MODStyleProperty alloc] initWithNameToken:nameToken valueTokens:valueTokens];
    }

    return nil;
}

@end
