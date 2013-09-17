//
//  MODLexerSpec.m
//  Mod
//
//  Created by Jonas Budelmann on 17/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODLexer.h"

@interface MODLexer ()
@property (nonatomic, strong) NSMutableString *str;
@end

SpecBegin(MODLexer)

it(@"should clean up carriage returns", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@"hello \r\n world \r"];
    expect(lexer.str).to.equal(@"hello \n world\n");
});

it(@"should clean up end of string", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@"hello \r\n  \r  \n   "];
    expect(lexer.str).to.equal(@"hello\n");
});

it(@"should return seperator", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@";  \t    hello"];
    expect(lexer.next.type).to.equal(MODTokenTypeSemiColon);
    expect(lexer.str).to.equal(@"hello");

    lexer = [[MODLexer alloc] initWithString:@";;  world hello"];
    expect(lexer.next.type).to.equal(MODTokenTypeSemiColon);
    expect(lexer.str).to.equal(@";  world hello");
});

it(@"should return space", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@"    \t   hello"];
    expect(lexer.next.type).to.equal(MODTokenTypeSpace);
    expect(lexer.str).to.equal(@"hello");
});

it(@"should return brace", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@"{  \t    hello"];
    expect(lexer.peek.type).to.equal(MODTokenTypeBrace);
    expect(lexer.peek.value).to.equal(@"{");
    expect(lexer.str).to.equal(@"  \t    hello");

    lexer = [[MODLexer alloc] initWithString:@"}{  world hello"];
    expect(lexer.peek.type).to.equal(MODTokenTypeBrace);
    expect(lexer.peek.value).to.equal(@"}");
    expect(lexer.str).to.equal(@"{  world hello");
});

SpecEnd