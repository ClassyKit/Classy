//
//  CASLexerSpec.m
//  Classy
//
//  Created by Jonas Budelmann on 17/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASLexer.h"
#import "UIColor+CASAdditions.h"

@interface CASLexer ()
@property (nonatomic, strong) NSMutableString *str;
@end

SpecBegin(CASLexer)

it(@"should clean up carriage returns", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"hello \r\n world \r"];
    expect(lexer.str).to.equal(@"hello \n world\n");
});

it(@"should clean up end of string", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"hello \r\n  \r  \n   "];
    expect(lexer.str).to.equal(@"hello\n");
});

it(@"should return EOS", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@""];
    expect([lexer lookaheadByCount:100].type).to.equal(CASTokenTypeEOS);
});

it(@"should return error", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"†"];
    expect(lexer.nextToken).to.beNil();
    expect(lexer.error.domain).to.equal(CASParseErrorDomain);
    expect(lexer.error.localizedDescription).to.equal(@"Invalid style string");
});

it(@"should return seperator", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@";  \t    hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeSemiColon);
    expect(lexer.str).to.equal(@"hello");

    lexer = [[CASLexer alloc] initWithString:@";;  world hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeSemiColon);
    expect(lexer.str).to.equal(@";  world hello");
});

it(@"should return space", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"    \t   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeSpace);
    expect(lexer.str).to.equal(@"hello");
});

it(@"should return curly brace", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"{  \t    hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeLeftCurlyBrace);
    expect(lexer.peekToken.value).to.equal(@"{");
    expect(lexer.str).to.equal(@"  \t    hello");

    lexer = [[CASLexer alloc] initWithString:@"}{  world hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeRightCurlyBrace);
    expect(lexer.peekToken.value).to.equal(@"}");
    expect(lexer.str).to.equal(@"{  world hello");
});

it(@"should return square brace", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"[  \t    hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeLeftSquareBrace);
    expect(lexer.peekToken.value).to.equal(@"[");
    expect(lexer.str).to.equal(@"  \t    hello");

    lexer = [[CASLexer alloc] initWithString:@"][  world hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeRightSquareBrace);
    expect(lexer.peekToken.value).to.equal(@"]");
    expect(lexer.str).to.equal(@"[  world hello");
});

it(@"should return ()", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"size(1,2,3,4)"];
    CASToken *token = lexer.nextToken;
    expect(token.type).to.equal(CASTokenTypeRef);
    expect(token.value).to.equal(@"size");
    expect(lexer.str).to.equal(@"(1,2,3,4)");

    token = lexer.nextToken;
    expect(token.type).to.equal(CASTokenTypeLeftRoundBrace);
    expect(token.value).to.equal(@"(");
    expect(lexer.str).to.equal(@"1,2,3,4)");

    token = [lexer lookaheadByCount:8];
    expect(token.type).to.equal(CASTokenTypeRightRoundBrace);
    expect(token.value).to.equal(@")");
    expect(lexer.str).to.equal(@"");
});

it(@"should return rgb UIColor", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"#fff   \t   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeColor);
    expect([lexer.peekToken.value cas_hexValue]).to.equal(@"ffffff");
    expect(lexer.str).to.equal(@"hello");
});

it(@"should return rrggbb UIColor", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"#ffffff   \t   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeColor);
    expect([lexer.peekToken.value cas_hexValue]).to.equal(@"ffffff");
    expect(lexer.str).to.equal(@"hello");
});

it(@"should return rrggbbaa UIColor", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"#ffffffff   \t   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeColor);
    expect([lexer.peekToken.value cas_hexValue]).to.equal(@"ffffff");
    expect(lexer.str).to.equal(@"hello");
});

it(@"should return string", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"\"    blah\"   '\"hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeString);
    expect(lexer.peekToken.value).to.equal(@"    blah");
    expect(lexer.str).to.equal(@"'\"hello");

    lexer = [[CASLexer alloc] initWithString:@"'  \"  blah''   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeString);
    expect(lexer.peekToken.value).to.equal(@"  \"  blah");
    expect(lexer.str).to.equal(@"'   hello");

    lexer = [[CASLexer alloc] initWithString:@"\"\"  a hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeString);
    expect(lexer.peekToken.value).to.equal(@"");
    expect(lexer.str).to.equal(@"a hello");
});

it(@"should return unit", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"1.5px   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeUnit);
    expect(lexer.peekToken.value).to.equal(@1.5);
    expect(lexer.str).to.equal(@"hello");

    lexer = [[CASLexer alloc] initWithString:@"-10.5pt   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeUnit);
    expect(lexer.peekToken.value).to.equal(@-10.5);
    expect(lexer.str).to.equal(@"hello");

    lexer = [[CASLexer alloc] initWithString:@"-20.5   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeUnit);
    expect(lexer.peekToken.value).to.equal(@-20.5);
    expect(lexer.str).to.equal(@"hello");
});

it(@"should return boolean", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"YES   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeBoolean);
    expect(lexer.peekToken.value).to.equal(@YES);
    expect(lexer.str).to.equal(@"hello");

    lexer = [[CASLexer alloc] initWithString:@"true   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeBoolean);
    expect(lexer.peekToken.value).to.equal(@YES);
    expect(lexer.str).to.equal(@"hello");

    lexer = [[CASLexer alloc] initWithString:@"NO   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeBoolean);
    expect(lexer.peekToken.value).to.equal(@NO);
    expect(lexer.str).to.equal(@"hello");

    lexer = [[CASLexer alloc] initWithString:@"false   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeBoolean);
    expect(lexer.peekToken.value).to.equal(@NO);
    expect(lexer.str).to.equal(@"hello");
});

it(@"should return selector", ^{
    // any character except `\n` | `{` | `,` | whitespace

    CASLexer *lexer = [[CASLexer alloc] initWithString:@".hello    world     {"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeSelector);
    expect(lexer.peekToken.value).to.equal(@".hello");
    expect(lexer.str).to.equal(@"    world     {");
});

it(@"should return ref", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"@background-color   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeRef);
    expect(lexer.peekToken.value).to.equal(@"@background-color");
    expect(lexer.str).to.equal(@"   hello");

    lexer = [[CASLexer alloc] initWithString:@"-----true;hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeRef);
    expect(lexer.peekToken.value).to.equal(@"-----true");
    expect(lexer.str).to.equal(@";hello");

    lexer = [[CASLexer alloc] initWithString:@"nicer_than-it--3454_(*^&;hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeRef);
    expect(lexer.peekToken.value).to.equal(@"nicer_than-it--3454_");
    expect(lexer.str).to.equal(@"(*^&;hello");

    lexer = [[CASLexer alloc] initWithString:@"@_background-_color   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeRef);
    expect(lexer.peekToken.value).to.equal(@"@_background-_color");
    expect(lexer.str).to.equal(@"   hello");
});

it(@"should skip comments", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"//hello world   \n   \n stuff"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeIndent);
    expect(lexer.peekToken.value).to.equal(nil);
    expect(lexer.peekToken.lineNumber).to.equal(3);
    expect(lexer.str).to.equal(@"stuff");

    lexer = [[CASLexer alloc] initWithString:@"/* hello \n \n world \n */  \n   \n stuff"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeSpace);
    expect(lexer.peekToken.value).to.equal(nil);
    expect(lexer.peekToken.lineNumber).to.equal(4);
    expect(lexer.str).to.equal(@"\n   \n stuff");

    //EOS
    lexer = [[CASLexer alloc] initWithString:@"//hello world again"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeEOS);
    expect(lexer.peekToken.value).to.equal(nil);
    expect(lexer.peekToken.lineNumber).to.equal(1);
    expect(lexer.str).to.equal(@"");

    lexer = [[CASLexer alloc] initWithString:@"/*hello world again"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeEOS);
    expect(lexer.peekToken.value).to.equal(nil);
    expect(lexer.peekToken.lineNumber).to.equal(1);
    expect(lexer.str).to.equal(@"");
});

it(@"should return ident", ^{
    NSString *string = @"UIView\n"
                        "  asdf";

    CASLexer *lexer = [[CASLexer alloc] initWithString:string];
    [lexer nextToken];
    CASToken *token = [lexer nextToken];

    expect(token.type).to.equal(CASTokenTypeIndent);
    expect(token.value).to.equal(nil);
    expect(token.lineNumber).to.equal(2);
    expect(lexer.str).to.equal(@"asdf");
});

it(@"should complain when mixing indentation types", ^{
    NSString *string = @"UIView\n"
                        "  spaces:2;\n"
                        "\ttabs:1;";
    CASLexer *lexer = [[CASLexer alloc] initWithString:string];
    while(lexer.peekToken && lexer.peekToken.type != CASTokenTypeEOS) {
        [lexer nextToken];
    }

    expect(lexer.error).notTo.beNil();
    expect(lexer.error.domain).to.equal(CASParseErrorDomain);
    expect(lexer.error.code).to.equal(CASParseErrorInvalidIndentation);
    expect(lexer.error.userInfo[CASParseFailingLineNumberErrorKey]).to.equal(@3);
    expect(lexer.error.userInfo[CASParseFailingStringErrorKey]).to.equal(@"\"\ttabs:1;\"");
});

it(@"should return outdent", ^{
    NSString *string = @"UIView{\n  asdf 1\n}";

    CASLexer *lexer = [[CASLexer alloc] initWithString:string];
    [lexer nextToken];
    [lexer nextToken];
    [lexer nextToken];
    [lexer nextToken];
    [lexer nextToken];
    [lexer nextToken];
    CASToken *token = lexer.nextToken;

    expect(token.type).to.equal(CASTokenTypeOutdent);
    expect(token.value).to.equal(nil);
    expect(token.lineNumber).to.equal(3);
    expect(lexer.str).to.equal(@"}");
});

it(@"should return Operator", ^{
    CASLexer *lexer = [[CASLexer alloc] initWithString:@",   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeOperator);
    expect(lexer.peekToken.value).to.equal(@",");
    expect(lexer.str).to.equal(@"hello");
});

SpecEnd