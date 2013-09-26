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

NSString * const MODParserErrorDomain = @"MODParserErrorDomain";
NSInteger const MODParserErrorFileContents = 2;

@interface MODParser ()

@property (nonatomic, strong) MODLexer *lexer;
@property (nonatomic, strong) NSMutableArray *styleGroups;
@property (nonatomic, strong) NSString *filePath;

@end

@implementation MODParser


- (id)initWithFilePath:(NSString *)filePath error:(NSError **)error {
    self = [super init];
    if (!self) return nil;

    NSError *fileError = nil;
    NSString *contents = [NSString stringWithContentsOfFile:filePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&fileError];

    if (!contents) {
        NSMutableDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Could not parse file",
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"File does not exist or is empty: %@", filePath]
        }.mutableCopy;

        if (fileError) {
            [userInfo setObject:fileError forKey:NSUnderlyingErrorKey];
        }
        *error = [NSError errorWithDomain:MODParserErrorDomain code:MODParserErrorFileContents userInfo:userInfo];

        return nil;
    }

    self.filePath = filePath;
    self.lexer = [[MODLexer alloc] initWithString:contents];
    self.styleGroups = NSMutableArray.new;

    return self;
}

- (void)parse {
    //TODO make `{` & `}` optional ie use identation to detect style groups
    //TODO support nested style groups

    MODLog(@"Start parsing file \n%@", self.filePath);
    MODStyleGroup *currentGroup = nil;
    while (self.peekToken.type != MODTokenTypeEOS) {
        MODStyleGroup *styleGroup = [self nextStyleGroup];
        if (styleGroup) {
            currentGroup = styleGroup;
            [self.styleGroups addObject:currentGroup];
            [self consumeTokenOfType:MODTokenTypeOpeningBrace];
            [self consumeTokenOfType:MODTokenTypeIndent];
            MODLog(@"(line %d) MODStyleGroup %@", self.peekToken.lineNumber, currentGroup);
            continue;
        }

        //not a style group therefore must be a property
        MODStyleProperty *styleProperty = [self nextStyleProperty];
        if (styleProperty.isValid) {
            NSAssert(currentGroup, @"Invalid style property `%@`. Needs to be within a style group. (line %d)",
                     styleProperty, self.peekToken.lineNumber);
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
        NSAssert(acceptableToken || closeGroup, @"Unexpected token `%@`. (line %d)",
                 self.nextToken, self.nextToken.lineNumber);
    }
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
    while (token.isPossiblySelector) {
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
    while (token.type != MODTokenTypeNewline
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
