//
//  MODParser.m
//  Mod
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODParser.h"
#import "MODLexer.h"
#import "MODNode.h"
#import "MODToken.h"

NSString * const MODParserErrorDomain = @"MODParserErrorDomain";
NSInteger const MODParserErrorFileContents = 2;

@interface MODParser ()

@property (nonatomic, strong) MODLexer *lexer;
@property (nonatomic, strong) MODNode *root;

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
    self.root = MODNode.new;
    return self;
}

- (void)parse {
    MODNode *root = self.root;
    while (self.peek.type != MODTokenTypeEOS) {
        if ([self acceptTokenOfType:MODTokenTypeNewline]) continue;
        MODNode *stmt = self.statement;
        [self acceptTokenOfType:MODTokenTypeSemiColon];
        NSAssert(stmt, @"unexpected token %@, not allowed at the root level", self.peek.value);
        [root addChildNode:stmt];
    }
}

- (MODToken *)peek {
    return self.lexer.peek;
}

- (MODToken *)next {
    return self.lexer.next;
}

- (MODNode *)statement {
    return nil;
}

- (MODToken *)acceptTokenOfType:(MODTokenType)type {
    if (type == self.peek.type) {
        //return token and remove from stack
        return self.next;
    }
    return nil;
}


@end
