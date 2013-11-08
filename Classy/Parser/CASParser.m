//
//  CASParser.m
//  Classy
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASParser.h"
#import "CASLexer.h"
#import "CASStyleNode.h"
#import "CASToken.h"
#import "CASUtilities.h"
#import "CASStyleProperty.h"
#import "CASStyleSelector.h"
#import "NSString+CASAdditions.h"

NSString * const CASParseFailingFilePathErrorKey = @"CASParseFailingFilePathErrorKey";
NSInteger const CASParseErrorFileContents = 2;

@interface CASParser ()

@property (nonatomic, strong) CASLexer *lexer;
@property (nonatomic, strong) NSMutableDictionary *styleVars;
@property (nonatomic, strong) NSError *error;

@end

@implementation CASParser

+ (NSArray *)stylesFromFilePath:(NSString *)filePath error:(NSError **)error {
    NSError *fileError = nil;
    NSString *contents = [NSString stringWithContentsOfFile:filePath
                                                   encoding:NSUTF8StringEncoding
                                                      error:&fileError];
    if (!contents || fileError) {
        NSMutableDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Could not parse file",
            NSLocalizedFailureReasonErrorKey: @"File does not exist or is empty",
            CASParseFailingFilePathErrorKey : filePath ?: @""
        }.mutableCopy;

        if (fileError) {
            [userInfo setObject:fileError forKey:NSUnderlyingErrorKey];
        }

        if (error) {
            *error = [NSError errorWithDomain:CASParseErrorDomain code:CASParseErrorFileContents userInfo:userInfo];
        }
        
        return nil;
    }

    CASLog(@"Start parsing file \n%@", filePath);
    NSError *parseError = nil;
    NSArray *styles = [self stylesFromString:contents error:&parseError];
    if (parseError) {
        NSMutableDictionary *userInfo = parseError.userInfo.mutableCopy;
        [userInfo addEntriesFromDictionary:@{ CASParseFailingFilePathErrorKey : filePath }];
        if (error) {
            *error = [NSError errorWithDomain:parseError.domain code:parseError.code userInfo:userInfo];
        }
        return nil;
    }

    return styles;
}

+ (NSArray *)stylesFromString:(NSString *)string error:(NSError **)error {
    CASParser *parser = CASParser.new;
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
            *error = [NSError errorWithDomain:CASParseErrorDomain code:CASParseErrorFileContents userInfo:userInfo];
        }
        return nil;
    }
    
    return styles;
}

- (NSError *)error {
    return _error ?: self.lexer.error;
}

- (NSArray *)parseString:(NSString *)string error:(NSError **)error {
    self.lexer = [[CASLexer alloc] initWithString:string];
    self.styleVars = NSMutableDictionary.new;

    NSMutableArray *allStyleNodes = NSMutableArray.new;
    NSMutableArray *styleNodesStack = NSMutableArray.new;
    NSMutableArray *stylePropertiesStack = NSMutableArray.new;

    while (self.peekToken.type != CASTokenTypeEOS) {
        if (self.error) {
            if (error) *error = self.error;
            return nil;
        }

        CASStyleProperty *styleVar = [self nextStyleVar];
        if (self.error) {
            if (error) *error = self.error;
            return nil;
        }

        if (styleVar) {
            if (styleNodesStack.count) {
                // can't have vars inside styleNodes
                if (error) {
                    *error = [self.lexer errorWithDescription:@"Variables cannot be declared inside style selectors"
                                                       reason:[NSString stringWithFormat:@"Variable: %@", styleVar]
                                                         code:CASParseErrorFileContents];
                }
                return nil;
            }
            [styleVar resolveExpressions];
            self.styleVars[styleVar.nameToken.value] = styleVar;
            [self consumeTokensMatching:^BOOL(CASToken *token) {
                return token.type == CASTokenTypeSpace || token.type == CASTokenTypeSemiColon;
            }];
            continue;
        }

        NSArray *styleNodes = [self nextStyleNodes];
        if (self.error) {
            if (error) *error = self.error;
            return nil;
        }

        if (styleNodes.count) {
            NSMutableArray *flattenStyleNodes = styleNodesStack.count ? NSMutableArray.new : nil;
            for (CASStyleNode *parentNode in styleNodesStack.lastObject) {
                for (CASStyleNode *styleNode in styleNodes) {
                    CASStyleNode *flattenStyleNode = CASStyleNode.new;
                    CASStyleSelector *parentSelector = [parentNode.styleSelector copy];
                    parentSelector.parent = YES;
                    if (styleNode.styleSelector.lastSelector.shouldConcatToParent) {
                        CASStyleSelector *styleSelector = styleNode.styleSelector;
                        if (styleSelector.styleClass) {
                            parentSelector.styleClass = styleSelector.styleClass;
                        }
                        if (styleSelector.arguments) {
                            parentSelector.arguments = styleSelector.arguments;
                        }
                        flattenStyleNode.styleSelector = parentSelector;
                    } else {
                        flattenStyleNode.styleSelector = [styleNode.styleSelector copy];
                        flattenStyleNode.styleSelector.lastSelector.parentSelector = parentSelector;
                    }
                    [flattenStyleNodes addObject:flattenStyleNode];
                }
            }
            if (flattenStyleNodes.count) {
                styleNodes = flattenStyleNodes;
            }

            [allStyleNodes addObjectsFromArray:styleNodes];
            [styleNodesStack addObject:styleNodes];
            [self consumeTokenOfType:CASTokenTypeLeftCurlyBrace];
            [self consumeTokenOfType:CASTokenTypeIndent];
            continue;
        }

        // not a style group therefore must be a property
        BOOL isStylePropertyParent = NO;
        CASStyleProperty *styleProperty = [self nextStylePropertyIsParent:&isStylePropertyParent];
        if (self.error) {
            if (error) *error = self.error;
            return nil;
        }

        if (styleProperty) {
            if (!styleNodesStack.count) {
                if (error) {
                    *error = [self.lexer errorWithDescription:@"Invalid style property"
                                                       reason:@"Needs to be within a style node"
                                                         code:CASParseErrorFileContents];
                }
                return nil;
            }
            [styleProperty resolveExpressions];

            if (stylePropertiesStack.count) {
                CASStyleProperty *parent = stylePropertiesStack.lastObject;
                [parent addChildStyleProperty:styleProperty];
            } else {
                for (CASStyleNode *node in styleNodesStack.lastObject) {
                    [node addStyleProperty:styleProperty];
                }
            }

            if (isStylePropertyParent) {
                [stylePropertiesStack addObject:styleProperty];
            }
            continue;
        }

        __block NSInteger previousLength = NSNotFound;
        __block CASToken *previousToken = nil;
        BOOL acceptableToken = [self consumeTokensMatching:^BOOL(CASToken *token) {
            BOOL popStack = token.type == CASTokenTypeOutdent || token.type == CASTokenTypeRightCurlyBrace;

            // make sure we don't double pop
            BOOL alreadyPopped = previousLength == self.lexer.length
                && previousToken.type == CASTokenTypeOutdent
                && token.type == CASTokenTypeRightCurlyBrace;

            if (!alreadyPopped && popStack) {
                NSMutableArray *stack = stylePropertiesStack.count ? stylePropertiesStack : styleNodesStack;
                if (stack.count) {
                    [stack removeObjectAtIndex:stack.count-1];
                }
            }

            previousLength = self.lexer.length;
            previousToken = token;
            return popStack || token.isWhitespace || token.type == CASTokenTypeSemiColon;
        }];

        if (!acceptableToken) {
            NSString *description = [NSString stringWithFormat:@"Unexpected token `%@`", self.nextToken];
            if (error) {
                *error = [self.lexer errorWithDescription:description
                                                   reason:@"Token does not belong in current context"
                                                     code:CASParseErrorFileContents];
            }
            return nil;
        }
    }

    return allStyleNodes;
}

#pragma mark - token helpers

- (CASToken *)peekToken {
    return self.lexer.peekToken;
}

- (CASToken *)nextToken {
    CASToken *token = self.lexer.nextToken;
    return token;
}

- (CASToken *)lookaheadByCount:(NSUInteger)count {
    return [self.lexer lookaheadByCount:count];
}

- (CASToken *)consumeTokenOfType:(CASTokenType)type {
    if (type == self.peekToken.type) {
        // return token and remove from stack
        return self.nextToken;
    }
    return nil;
}

- (BOOL)consumeTokensMatching:(BOOL(^)(CASToken *token))matchBlock {
    BOOL anyMatches = NO;
    while (matchBlock(self.peekToken)) {
        anyMatches = YES;
        [self nextToken];
    }
    return anyMatches;
}

- (BOOL)isNestedPropertyAtIndex:(NSInteger)index {
    NSInteger tail = index;
    while (--tail > 0) {
        CASToken *tailToken = [self lookaheadByCount:tail];
        if ([tailToken valueIsEqualTo:@"@"]) {
            return YES;
        }
        if (!tailToken.isWhitespace && tailToken.type != CASTokenTypeLeftCurlyBrace) {
            return NO;
        }
    }
    return NO;
}

#pragma mark - nodes

- (CASStyleProperty *)nextStyleVar {
    // variable if following seq: CASTokenTypeRef, `=`, any token until newline
    NSInteger i = 1;
    CASToken *token = [self lookaheadByCount:i];
    BOOL hasEqualsSign = NO;
    CASToken *refToken;

    while (token && token.isPossiblyVar && !(hasEqualsSign && refToken)) {
        if (token.type == CASTokenTypeRef) {
            refToken = token;
        }
        if (refToken && [token valueIsEqualTo:@"="]) {
            hasEqualsSign = YES;
        }
        token = [self lookaheadByCount:++i];
    }

    if ([refToken.value hasPrefix:@"@"]) {
        self.error = [self.lexer errorWithDescription:@"Variables cannot begin with `@` character"
                                               reason:@"`@` is reserved for @media, @version and property lookup"
                                                 code:CASParseErrorFileContents];
    }

    if (hasEqualsSign && refToken) {
        // consume LHS of var
        while (--i >= 0) {
            [self nextToken];
        }

        // collect value tokens, enclose in ()
        NSMutableArray *valueTokens = NSMutableArray.new;
        [valueTokens addObject:[CASToken tokenOfType:CASTokenTypeLeftRoundBrace]];
        while (token.type != CASTokenTypeNewline && token.type != CASTokenTypeSemiColon) {
            [valueTokens addObject:token];
            token = [self nextToken];
        }
        [valueTokens addObject:[CASToken tokenOfType:CASTokenTypeRightRoundBrace]];

        return [[CASStyleProperty alloc] initWithNameToken:refToken valueTokens:valueTokens];
    }
    return nil;
}

- (NSArray *)nextStyleNodes {
    NSInteger i = 1;
    CASToken *token = [self lookaheadByCount:i];
    while (token && token.isPossiblySelector) {
        token = [self lookaheadByCount:++i];
    }

    if ([self isNestedPropertyAtIndex:i]) {
        return nil;
    }

    if (token.type != CASTokenTypeLeftCurlyBrace && token.type != CASTokenTypeIndent) {
        return nil;
    }

    NSMutableArray *styleNodes = NSMutableArray.new;
    NSMutableDictionary *arguments;
    CASStyleSelector *styleSelector;
    CASToken *previousToken, *argNameToken, *argValueToken;
    token = nil;
    BOOL shouldSelectSubclasses = NO;
    BOOL shouldSelectIndirectSuperview = YES;
    BOOL argumentListMode = NO;
    BOOL shouldConcatToParent = NO;

    while (--i > 0) {
        previousToken = token;
        token = [self nextToken];

        if (argumentListMode) {
            if (token.type == CASTokenTypeRightSquareBrace) {
                styleSelector.arguments = [arguments copy];
                argumentListMode = NO;
                arguments = nil;
            } else if (token.type == CASTokenTypeSelector || token.type == CASTokenTypeRef) {
                if (!argNameToken) {
                    argNameToken = token;
                } else if (!argValueToken) {
                    argValueToken = token;
                }

                if (argNameToken && argValueToken) {
                    if (!arguments) {
                        arguments = NSMutableDictionary.new;
                    }
                    NSString *argValue = [argValueToken.value cas_stringByTrimmingWhitespace];
                    NSString *argName = [argNameToken.value cas_stringByTrimmingWhitespace];
                    [arguments setObject:argValue forKey:argName];

                    argValueToken = nil;
                    argNameToken = nil;
                }
            }
            continue;
        }

        if (token.type == CASTokenTypeCarat) {
            shouldSelectSubclasses = YES;
        } else if (token.type == CASTokenTypeRef || token.type == CASTokenTypeSelector) {
            NSString *tokenValue = [token.value cas_stringByTrimmingWhitespace];

            BOOL shouldSpawn = ![tokenValue hasPrefix:@"."]
                                || styleSelector == nil
                                || previousToken.isWhitespace
                                || [previousToken valueIsEqualTo:@">"];

            if (shouldSpawn) {
                if (styleSelector) {
                    CASStyleSelector *childSelector = CASStyleSelector.new;
                    childSelector.shouldSelectIndirectSuperview = shouldSelectIndirectSuperview;
                    childSelector.shouldConcatToParent = shouldConcatToParent;
                    childSelector.parentSelector = styleSelector;
                    styleSelector.parent = YES;

                    styleSelector = childSelector;
                } else {
                    styleSelector = CASStyleSelector.new;
                    styleSelector.shouldSelectIndirectSuperview = shouldSelectIndirectSuperview;
                    styleSelector.shouldConcatToParent = shouldConcatToParent;
                }
            }

            styleSelector.shouldSelectSubclasses = shouldSelectSubclasses;

            if ([tokenValue hasPrefix:@"."]) {
                styleSelector.styleClass = [tokenValue substringFromIndex:1];
            } else {
                styleSelector.objectClass = NSClassFromString(tokenValue);
            }

            if (!styleSelector.objectClass && !shouldConcatToParent) {
                self.error = [self.lexer errorWithDescription:[NSString stringWithFormat:@"Invalid class name `%@`", tokenValue]
                                                       reason:@"Every selector must have a objectClass"
                                                         code:CASParseErrorFileContents];
                return nil;
            }

            // reset state
            shouldSelectSubclasses = NO;
            shouldSelectIndirectSuperview = YES;
            shouldConcatToParent = NO;
        } else if (token.type == CASTokenTypeLeftSquareBrace) {
            argumentListMode = YES;
        } else if ([token valueIsEqualTo:@"&"]) {
            shouldConcatToParent = YES;
        } else if([token valueIsEqualTo:@">"]) {
            shouldSelectIndirectSuperview = NO;
        } else if ([token valueIsEqualTo:@","]) {
            if (styleSelector) {
                CASStyleNode *node = CASStyleNode.new;
                node.styleSelector = styleSelector;
                [styleNodes addObject:node];
            }
            styleSelector = nil;
        }
    }
    if (styleSelector) {
        CASStyleNode *node = CASStyleNode.new;
        node.styleSelector = styleSelector;
        [styleNodes addObject:node];
    }

    return styleNodes;
}

- (CASStyleProperty *)nextStylePropertyIsParent:(BOOL *)isParent {
    NSInteger i = 1;

    BOOL hasName = NO, hasValues = NO;
    CASToken *token = [self lookaheadByCount:i];
    while (token && token.type != CASTokenTypeNewline
           && token.type != CASTokenTypeRightCurlyBrace
           && token.type != CASTokenTypeIndent
           && token.type != CASTokenTypeOutdent
           && token.type != CASTokenTypeSemiColon
           && token.type != CASTokenTypeEOS) {

        if (token.type == CASTokenTypeSpace
            || token.type == CASTokenTypeIndent
            || [token valueIsEqualTo:@":"]) {
            token = [self lookaheadByCount:++i];
            continue;
        }

        if (!hasName && token.value) {
            hasName = YES;
        } else {
            hasValues = YES;
        }
        token = [self lookaheadByCount:++i];
    }

    if (hasName && hasValues) {
        CASToken *nameToken;
        NSMutableArray *valueTokens = NSMutableArray.new;
        NSMutableDictionary *arguments;
        CASToken *argNameToken, *argValueToken;
        BOOL argumentListMode = NO;
        BOOL hasChildren = [self isNestedPropertyAtIndex:i];

        // consume tokens
        while (--i > 0) {
            token = [self nextToken];

            if (!nameToken && token.value) {
                nameToken = token;
                continue;
            }

            if (argumentListMode) {
                if (token.type == CASTokenTypeRightSquareBrace) {
                    argumentListMode = NO;
                } else if (token.type == CASTokenTypeSelector || token.type == CASTokenTypeRef) {
                    if (!argNameToken) {
                        argNameToken = token;
                    } else if (!argValueToken) {
                        argValueToken = token;
                    }

                    if (argNameToken && argValueToken) {
                        if (!arguments) {
                            arguments = NSMutableDictionary.new;
                        }
                        NSString *argValue = [argValueToken.value cas_stringByTrimmingWhitespace];
                        NSString *argName = [argNameToken.value cas_stringByTrimmingWhitespace];
                        [arguments setObject:argValue forKey:argName];

                        argValueToken = nil;
                        argNameToken = nil;
                    }
                }
                continue;
            }

            if (token.isWhitespace || [token valueIsEqualTo:@":"]) {
                continue;
            }
            if (token.type == CASTokenTypeLeftSquareBrace) {
                argumentListMode = YES;
            } else if (token.type == CASTokenTypeRef) {
                CASStyleProperty *styleVar = self.styleVars[token.value];
                if (styleVar) {
                    [valueTokens addObjectsFromArray:styleVar.valueTokens];
                } else {
                    [valueTokens addObject:token];
                }
            } else {
                [valueTokens addObject:token];
            }
        }
        CASStyleProperty *styleProperty = [[CASStyleProperty alloc] initWithNameToken:nameToken valueTokens:valueTokens];
        styleProperty.arguments = [arguments copy];
        *isParent = hasChildren;
        return styleProperty;
    }

    return nil;
}

@end
