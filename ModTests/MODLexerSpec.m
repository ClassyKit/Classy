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
    expect(lexer.peekToken.type).to.equal(MODTokenTypeOpeningBrace);
    expect(lexer.str).to.equal(@"  \t    hello");

    lexer = [[MODLexer alloc] initWithString:@"}{  world hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeClosingBrace);
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

it(@"should return unit", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@"1.5px   hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeUnit);
    expect(lexer.peekToken.value).to.equal(@1.5);
    expect(lexer.str).to.equal(@"hello");

    lexer = [[MODLexer alloc] initWithString:@"-10.5pt   hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeUnit);
    expect(lexer.peekToken.value).to.equal(@-10.5);
    expect(lexer.str).to.equal(@"hello");

    lexer = [[MODLexer alloc] initWithString:@"-20.5   hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeUnit);
    expect(lexer.peekToken.value).to.equal(@-20.5);
    expect(lexer.str).to.equal(@"hello");
});

it(@"should return boolean", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@"YES   hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeBoolean);
    expect(lexer.peekToken.value).to.equal(@YES);
    expect(lexer.str).to.equal(@"hello");

    lexer = [[MODLexer alloc] initWithString:@"true   hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeBoolean);
    expect(lexer.peekToken.value).to.equal(@YES);
    expect(lexer.str).to.equal(@"hello");

    lexer = [[MODLexer alloc] initWithString:@"NO   hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeBoolean);
    expect(lexer.peekToken.value).to.equal(@NO);
    expect(lexer.str).to.equal(@"hello");

    lexer = [[MODLexer alloc] initWithString:@"false   hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeBoolean);
    expect(lexer.peekToken.value).to.equal(@NO);
    expect(lexer.str).to.equal(@"hello");
});

it(@"should return selector", ^{
    // any character except `\n` | `{` | `,` and stop if encounter `//` unless its inbetween `[ ]`

    MODLexer *lexer = [[MODLexer alloc] initWithString:@".hello    world     {"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeSelector);
    expect(lexer.peekToken.value).to.equal(@".hello    world     ");
    expect(lexer.str).to.equal(@"{");

    lexer = [[MODLexer alloc] initWithString:@"^&*@#$_+!hello    world[asd//aa]     ,"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeSelector);
    expect(lexer.peekToken.value).to.equal(@"^&*@#$_+!hello    world[asd//aa]     ");
    expect(lexer.str).to.equal(@",");
});

it(@"should return ref", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@"@background-color   hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeRef);
    expect(lexer.peekToken.value).to.equal(@"@background-color");
    expect(lexer.str).to.equal(@"   hello");

    lexer = [[MODLexer alloc] initWithString:@"-----true;hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeRef);
    expect(lexer.peekToken.value).to.equal(@"-----true");
    expect(lexer.str).to.equal(@";hello");

    lexer = [[MODLexer alloc] initWithString:@"nicer_than-it--3454_(*^&;hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeRef);
    expect(lexer.peekToken.value).to.equal(@"nicer_than-it--3454_");
    expect(lexer.str).to.equal(@"(*^&;hello");

    lexer = [[MODLexer alloc] initWithString:@"@_background-_color   hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeRef);
    expect(lexer.peekToken.value).to.equal(@"@_background-_color");
    expect(lexer.str).to.equal(@"   hello");
});

it(@"should skip comments", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@"//hello world   \n   \n stuff"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeIndent);
    expect(lexer.peekToken.value).to.equal(nil);
    expect(lexer.peekToken.lineNumber).to.equal(3);
    expect(lexer.str).to.equal(@"stuff");

    lexer = [[MODLexer alloc] initWithString:@"/* hello \n \n world \n */  \n   \n stuff"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeSpace);
    expect(lexer.peekToken.value).to.equal(nil);
    expect(lexer.peekToken.lineNumber).to.equal(4);
    expect(lexer.str).to.equal(@"\n   \n stuff");
});

it(@"should return ident", ^{
    NSString *string = @"UIView\n"
                        "  asdf";

    MODLexer *lexer = [[MODLexer alloc] initWithString:string];
    [lexer nextToken];
    MODToken *token = [lexer nextToken];

    expect(token.type).to.equal(MODTokenTypeIndent);
    expect(token.value).to.equal(nil);
    expect(token.lineNumber).to.equal(2);
    expect(lexer.str).to.equal(@"asdf");
});

it(@"should return outdent", ^{
    NSString *string = @"UIView{\n  asdf 1\n}";

    MODLexer *lexer = [[MODLexer alloc] initWithString:string];
    [lexer nextToken];
    [lexer nextToken];
    [lexer nextToken];
    [lexer nextToken];
    [lexer nextToken];
    [lexer nextToken];
    MODToken *token = lexer.nextToken;

    expect(token.type).to.equal(MODTokenTypeOutdent);
    expect(token.value).to.equal(nil);
    expect(token.lineNumber).to.equal(3);
    expect(lexer.str).to.equal(@"}");
});

it(@"should return Operator", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@",   hello"];
    expect(lexer.peekToken.type).to.equal(MODTokenTypeOperator);
    expect(lexer.peekToken.value).to.equal(@",");
    expect(lexer.str).to.equal(@"hello");
});

SpecEnd