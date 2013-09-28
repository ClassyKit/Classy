//
//  MODParser.m
//  Mod
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODParser.h"
#import "MODLexer.h"
#import "MODStyleGroup.h"
#import "MODToken.h"
#import "MODLog.h"
#import "MODStyleProperty.h"

NSString * const MODParseFailingFilePathErrorKey = @"MODParseFailingFilePathErrorKey";
NSInteger const MODParseErrorFileContents = 2;

@interface MODParser ()

@property (nonatomic, strong) MODLexer *lexer;

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
            MODParseFailingFilePathErrorKey : filePath
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
    NSArray *styleGroups = [self stylesFromString:contents error:&parseError];
    if (parseError) {
        NSMutableDictionary *userInfo = parseError.userInfo.mutableCopy;
        [userInfo addEntriesFromDictionary:@{ MODParseFailingFilePathErrorKey : filePath }];
        if (error) {
            *error = [NSError errorWithDomain:parseError.domain code:parseError.code userInfo:userInfo];
        }
        return nil;
    }

    return styleGroups;
}

+ (NSArray *)stylesFromString:(NSString *)string error:(NSError **)error {
    MODParser *parser = MODParser.new;
    NSError *parseError = nil;
    NSArray *styleGroups = [parser parseString:string error:&parseError];

    if (!styleGroups.count) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Could not parse string",
            NSLocalizedFailureReasonErrorKey: @"Could not find any styles"
        };
        if (error) {
            *error = [NSError errorWithDomain:MODParseErrorDomain code:MODParseErrorFileContents userInfo:userInfo];
        }
        return nil;
    }
    if (parseError) {
        if (error) {
            *error = parseError;
        }
        return nil;
    }
    
    return styleGroups;
}

- (NSArray *)parseString:(NSString *)string error:(NSError **)error {
    self.lexer = [[MODLexer alloc] initWithString:string];

    NSMutableArray *styleGroups = NSMutableArray.new;
    MODStyleGroup *currentGroup = nil;
    while (self.peekToken.type != MODTokenTypeEOS) {
        if (self.lexer.error) {
            if (error) {
                *error = self.lexer.error;
            }
            return nil;
        }

        MODStyleGroup *styleGroup = [self nextStyleGroup];
        if (styleGroup) {
            currentGroup = styleGroup;
            [styleGroups addObject:currentGroup];
            [self consumeTokenOfType:MODTokenTypeOpeningBrace];
            [self consumeTokenOfType:MODTokenTypeIndent];
            MODLog(@"(line %d) MODStyleGroup %@", self.peekToken.lineNumber, currentGroup);
            continue;
        }

        //not a style group therefore must be a property
        MODStyleProperty *styleProperty = [self nextStyleProperty];
        if (styleProperty.isValid) {
            if (!currentGroup) {
                if (error) {
                    *error = [self.lexer errorWithDescription:@"Invalid style property"
                                                       reason:@"Needs to be within a style group"
                                                         code:MODParseErrorFileContents];
                }
                return nil;
            }
            [currentGroup addStyleProperty:styleProperty];
            MODLog(@"(line %d) MODStyleProperty `%@`", self.peekToken.lineNumber, styleProperty);
            continue;
        }

        BOOL closeGroup = [self consumeTokensMatching:^BOOL(MODToken *token) {
            return token.type == MODTokenTypeOutdent || token.type == MODTokenTypeClosingBrace;
        }];
        if (closeGroup) {
            currentGroup = nil;
        }

        BOOL acceptableToken = [self consumeTokensMatching:^BOOL(MODToken *token) {
            return token.isWhitespace || token.type == MODTokenTypeSemiColon;
        }];
        if (!acceptableToken && !closeGroup) {
            NSString *description = [NSString stringWithFormat:@"Unexpected token `%@`", self.nextToken];
            if (error) {
                *error = [self.lexer errorWithDescription:description
                                                   reason:@"Token does not belong in current context"
                                                     code:MODParseErrorFileContents];
            }
            return nil;
        }
    }

    return styleGroups;
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

- (MODStyleGroup *)nextStyleGroup {
    NSInteger i = 1;
    MODStyleGroup *styleGroup = MODStyleGroup.new;
    NSMutableString *currentSelector = NSMutableString.new;

    MODToken *token = [self lookaheadByCount:i];
    while (token && token.isPossiblySelector) {
        if ([token valueIsEqualTo:@","]) {
            [styleGroup addSelector:currentSelector];
            currentSelector = NSMutableString.new;
        } else if(token.isWhitespace) {
            [currentSelector appendString:@" "];
        } else if ([token.value length]) {
            [currentSelector appendString:token.value];
        }
        token = [self lookaheadByCount:++i];
    }
    [styleGroup addSelector:currentSelector];

    if (token.type == MODTokenTypeOpeningBrace || token.type == MODTokenTypeIndent) {
        while (--i > 0) {
            [self nextToken];
        }
        return styleGroup;
    }

    return nil;
}

- (MODStyleProperty *)nextStyleProperty {
    NSInteger i = 1;
    MODToken *nameToken;
    NSMutableArray *valueTokens = NSMutableArray.new;

    MODToken *token = [self lookaheadByCount:i];
    while (token && token.type != MODTokenTypeNewline
           && token.type != MODTokenTypeOpeningBrace
           && token.type != MODTokenTypeClosingBrace
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

    MODStyleProperty *styleProperty = [[MODStyleProperty alloc] initWithNameToken:nameToken valueTokens:valueTokens];
    if (styleProperty.isValid) {
        //consume tokens
        while (--i > 0) {
            MODToken *token = [self nextToken];
            MODLog(@"(line %d) skipping %@", token.lineNumber, token);
        }
    }

    return styleProperty;
}

@end
