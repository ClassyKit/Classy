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
    MODLog(@"Start parsing file \n%@", self.filePath);
    MODStyleGroup *currentGroup = nil;
    while (self.peekToken.type != MODTokenTypeEOS) {
        NSArray *selectors = self.selectorTokens;
        if (selectors.count) {
            currentGroup = MODStyleGroup.new;
            currentGroup.selectors = selectors;
            [self.styleGroups addObject:currentGroup];
            MODLog(@"(line %d) selectors %@", self.peekToken.lineNumber, selectors);
            continue;
        }

        MODLog(@"(line %d) token `%@`", self.peekToken.lineNumber, self.peekToken);
        [self nextToken];
    }
}

#pragma mark - token helpers

- (MODToken *)peekToken {
    return self.lexer.peekToken;
}

- (MODToken *)nextToken {
    return self.lexer.nextToken;
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

#pragma mark - nodes

- (NSArray *)selectorTokens {
    //primitive selector detection
    NSInteger i = 0;
    NSMutableArray *selectors = NSMutableArray.new;
    NSMutableString *currentSelector = NSMutableString.new;

    void (^addSelector)(NSString *) = ^(NSString *aSelector){
        NSString *selector = [aSelector stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \n"]];
        if (selector.length) {
            [selectors addObject:selector];
        }
    };

    MODToken *token = [self lookaheadByCount:++i];
    while (token.isPossiblySelector) {
        if ([token valueIsEqualToString:@","]) {
            addSelector(currentSelector);
            currentSelector = NSMutableString.new;
        } else if(token.isWhitespace) {
            [currentSelector appendString:@" "];
        } else if ([token.value length]) {
            [currentSelector appendString:token.value];
        }
        token = [self lookaheadByCount:++i];
    }
    addSelector(currentSelector);
    
    if (token.type == MODTokenTypeOpeningBrace) {
        //consume tokens
        while (--i > 0) {
            [self nextToken];
        }
        return selectors;
    }

    return nil;
}


@end
