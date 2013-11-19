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

- (void)testCleanUpCarriageReturns {
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"hello \r\n world \r"];
    expect(lexer.str).to.equal(@"hello \n world\n");
}

- (void)testCleanUpEndOfString {
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"hello \r\n  \r  \n   "];
    expect(lexer.str).to.equal(@"hello\n");
}

- (void)testReturnEOS {
    CASLexer *lexer = [[CASLexer alloc] initWithString:@""];
    expect([lexer lookaheadByCount:100].type).to.equal(CASTokenTypeEOS);
}

- (void)testReturnError {
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"†"];
    expect(lexer.nextToken).to.beNil();
    expect(lexer.error.domain).to.equal(CASParseErrorDomain);
    expect(lexer.error.localizedDescription).to.equal(@"Invalid style string");
}

- (void)testReturnSeperator {
    CASLexer *lexer = [[CASLexer alloc] initWithString:@";  \t    hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeSemiColon);
    expect(lexer.str).to.equal(@"hello");

    lexer = [[CASLexer alloc] initWithString:@";;  world hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeSemiColon);
    expect(lexer.str).to.equal(@";  world hello");
}

- (void)testReturnSpace {
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"    \t   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeSpace);
    expect(lexer.str).to.equal(@"hello");
}

- (void)testReturnCurlyBrace {
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"{  \t    hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeLeftCurlyBrace);
    expect(lexer.peekToken.value).to.equal(@"{");
    expect(lexer.str).to.equal(@"  \t    hello");

    lexer = [[CASLexer alloc] initWithString:@"}{  world hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeRightCurlyBrace);
    expect(lexer.peekToken.value).to.equal(@"}");
    expect(lexer.str).to.equal(@"{  world hello");
}

- (void)testReturnSquareBrace {
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"[  \t    hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeLeftSquareBrace);
    expect(lexer.peekToken.value).to.equal(@"[");
    expect(lexer.str).to.equal(@"  \t    hello");

    lexer = [[CASLexer alloc] initWithString:@"][  world hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeRightSquareBrace);
    expect(lexer.peekToken.value).to.equal(@"]");
    expect(lexer.str).to.equal(@"[  world hello");
}

- (void)testReturnRoundBraces {
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
}

- (void)testReturnRgbUIColor {
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"#fff   \t   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeColor);
    expect([lexer.peekToken.value cas_hexValue]).to.equal(@"ffffff");
    expect(lexer.str).to.equal(@"hello");
}

- (void)testReturnRrggbbUIColor {
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"#ffffff   \t   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeColor);
    expect([lexer.peekToken.value cas_hexValue]).to.equal(@"ffffff");
    expect(lexer.str).to.equal(@"hello");
}

- (void)testReturnRrggbbaaUIColor {
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"#ffffffff   \t   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeColor);
    expect([lexer.peekToken.value cas_hexValue]).to.equal(@"ffffff");
    expect(lexer.str).to.equal(@"hello");
}

- (void)testReturnString {
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
}

- (void)testReturnUnit {
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
}

- (void)testReturnBoolean {
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
}

- (void)testReturnSelector {
    // any character except `\n` | `{` | `,` | whitespace

    CASLexer *lexer = [[CASLexer alloc] initWithString:@".hello    world     {"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeSelector);
    expect(lexer.peekToken.value).to.equal(@".hello");
    expect(lexer.str).to.equal(@"    world     {");
}

- (void)testReturnRef {
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
}

- (void)testSkipComments {
    CASLexer *lexer = [[CASLexer alloc] initWithString:@"//hello world   \n   \n stuff"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeIndent);
    expect(lexer.peekToken.value).to.equal(nil);
    expect(lexer.peekToken.lineNumber).to.equal(3);
    expect(lexer.str).to.equal(@"stuff");

    lexer = [[CASLexer alloc] initWithString:@"/* hello \n \n world \n */  \n   \n stuff"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeSpace);
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
}

- (void)testReturnIdent {
    NSString *string = @"UIView\n"
                        "  asdf";

    CASLexer *lexer = [[CASLexer alloc] initWithString:string];
    [lexer nextToken];
    CASToken *token = [lexer nextToken];

    expect(token.type).to.equal(CASTokenTypeIndent);
    expect(token.value).to.equal(nil);
    expect(token.lineNumber).to.equal(2);
    expect(lexer.str).to.equal(@"asdf");
}

- (void)testComplainWhenMixingIndentationTypes {
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
}

- (void)testReturnOutdent {
    NSString *string =
    @"UIButton\n"
    "  background-color\n"
    "  border-width 1\n"
    "  > UIControl\n"
    "    amazing 23\n"
    "  UISlider\n"
    "    another 34\n"
    "b";

    CASLexer *lexer = [[CASLexer alloc] initWithString:string];
    expect([[lexer lookaheadByCount:1] value]).to.equal(@"UIButton");
    expect([[lexer lookaheadByCount:2] type]).to.equal(CASTokenTypeIndent);
    expect([[lexer lookaheadByCount:3] value]).to.equal(@"background-color");
    expect([[lexer lookaheadByCount:4] type]).to.equal(CASTokenTypeNewline);
    expect([[lexer lookaheadByCount:5] value]).to.equal(@"border-width");
    expect([[lexer lookaheadByCount:6] type]).to.equal(CASTokenTypeSpace);
    expect([[lexer lookaheadByCount:7] value]).to.equal(@1);
    expect([[lexer lookaheadByCount:8] type]).to.equal(CASTokenTypeNewline);
    expect([[lexer lookaheadByCount:9] value]).to.equal(@">");
    expect([[lexer lookaheadByCount:10] value]).to.equal(@"UIControl");
    expect([[lexer lookaheadByCount:11] type]).to.equal(CASTokenTypeIndent);
    expect([[lexer lookaheadByCount:12] value]).to.equal(@"amazing");
    expect([[lexer lookaheadByCount:13] type]).to.equal(CASTokenTypeSpace);
    expect([[lexer lookaheadByCount:14] value]).to.equal(@23);
    expect([[lexer lookaheadByCount:15] type]).to.equal(CASTokenTypeOutdent);
    expect([[lexer lookaheadByCount:16] value]).to.equal(@"UISlider");
    expect([[lexer lookaheadByCount:17] type]).to.equal(CASTokenTypeIndent);
    expect([[lexer lookaheadByCount:18] value]).to.equal(@"another");
    expect([[lexer lookaheadByCount:19] type]).to.equal(CASTokenTypeSpace);
    expect([[lexer lookaheadByCount:20] value]).to.equal(@34);
    expect([[lexer lookaheadByCount:21] type]).to.equal(CASTokenTypeOutdent);
    expect([[lexer lookaheadByCount:22] type]).to.equal(CASTokenTypeOutdent);
    expect([[lexer lookaheadByCount:23] value]).to.equal(@"b");
    expect([[lexer lookaheadByCount:24] type]).to.equal(CASTokenTypeEOS);

}

- (void)testReturnOperator {
    CASLexer *lexer = [[CASLexer alloc] initWithString:@",   hello"];
    expect(lexer.peekToken.type).to.equal(CASTokenTypeOperator);
    expect(lexer.peekToken.value).to.equal(@",");
    expect(lexer.str).to.equal(@"hello");
}

SpecEnd