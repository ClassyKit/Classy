//
//  MODLexerSpec.m
//  Mod
//
//  Created by Jonas Budelmann on 17/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODLexer.h"
#import "UIColor+MODAdditions.h"

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
    expect(lexer.peekToken.type).to.equal(MODTokenTypeSemiColon);
    expect(lexer.str).to.equal(@"hello");

    lexer = [[MODLexer alloc] initWithString:@";;  world hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeSemiColon);
    expect(lexer.str).to.equal(@";  world hello");
});

it(@"should return space", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@"    \t   hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeSpace);
    expect(lexer.str).to.equal(@"hello");
});

it(@"should return brace", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@"{  \t    hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeBrace);
    expect(lexer.peekToken.value).to.equal(@"{");
    expect(lexer.str).to.equal(@"  \t    hello");

    lexer = [[MODLexer alloc] initWithString:@"}{  world hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeBrace);
    expect(lexer.peekToken.value).to.equal(@"}");
    expect(lexer.str).to.equal(@"{  world hello");
});

it(@"should return rgb UIColor", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@"#fff   \t   hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeColor);
    expect([lexer.peekToken.value mod_hexValue]).to.equal(@"ffffff");
    expect(lexer.str).to.equal(@"hello");
});

it(@"should return rrggbb UIColor", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@"#ffffff   \t   hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeColor);
    expect([lexer.peekToken.value mod_hexValue]).to.equal(@"ffffff");
    expect(lexer.str).to.equal(@"hello");
});

it(@"should return rrggbbaa UIColor", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@"#ffffffff   \t   hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeColor);
    expect([lexer.peekToken.value mod_hexValue]).to.equal(@"ffffff");
    expect(lexer.str).to.equal(@"hello");
});

it(@"should return string", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@"\"    blah\"   '\"hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeString);
    expect(lexer.peekToken.value).to.equal(@"    blah");
    expect(lexer.str).to.equal(@"'\"hello");

    lexer = [[MODLexer alloc] initWithString:@"'  \"  blah''   hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeString);
    expect(lexer.peekToken.value).to.equal(@"  \"  blah");
    expect(lexer.str).to.equal(@"'   hello");

    lexer = [[MODLexer alloc] initWithString:@"\"\"  a hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeString);
    expect(lexer.peekToken.value).to.equal(@"");
    expect(lexer.str).to.equal(@"a hello");
});

SpecEnd