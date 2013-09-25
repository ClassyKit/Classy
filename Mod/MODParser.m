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

NSString * const MODParserErrorDomain = @"MODParserErrorDomain";
NSInteger const MODParserErrorFileContents = 2;

@interface MODParser ()

@property (nonatomic, strong) MODLexer *lexer;
@property (nonatomic, strong) NSMutableArray *styleGroups;

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

    self.lexer = [[MODLexer alloc] initWithString:contents];
    self.styleGroups = NSMutableArray.new;
    return self;
}

- (void)parse {
    MODStyleGroup *currentGroup = nil;
    while (self.peekToken.type != MODTokenTypeEOS) {
        NSArray *selectors = self.selectorTokens;
        if (selectors.count) {
            currentGroup = MODStyleGroup.new;
            currentGroup.selectors = selectors;
            [self.styleGroups addObject:currentGroup];
            continue;
        }

        NSLog(@"TODO token %@ at line number %d", self.peekToken, self.peekToken.lineNumber);
        [self nextToken];
//        if ([self consumeTokenOfType:MODTokenTypeNewline]) continue;
//        MODNode *stmt = self.statement;
//        [self consumeTokenOfType:MODTokenTypeSemiColon];
//        NSAssert(stmt, @"unexpected token %@ at line number %d, not allowed at the root level", self.peekToken, self.peekToken.lineNumber);
//        [root addChildNode:stmt];
    }
}

#pragma mark - token helpers

- (MODToken *)peekToken {
    return self.lexer.peekToken;
}

- (MODToken *)nextToken {
    return self.lexer.nextToken;
}

- (MODToken *)lookahead:(NSUInteger)n {
    return [self.lexer lookahead:n];
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

    MODToken *token;
    do {
        token = [self lookahead:++i];
        if (token.type == MODTokenTypeRef) {
            [selectors addObject:token];
        }
    } while (token.type == MODTokenTypeRef
             || token.isWhitespace
             || [token valueIsEqualToString:@","]);

    if ([self lookahead:i].type == MODTokenTypeOpeningBrace) {
        //consume tokens
        while (--i > 0) {
            [self nextToken];
        }
        return selectors;
    }

    return nil;
}


@end
