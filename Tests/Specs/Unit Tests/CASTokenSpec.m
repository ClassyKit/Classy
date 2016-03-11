//
//  CASTokenSpec.m
//  Classy
//
//  Created by Jonas Budelmann on 24/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASToken.h"
#import "XCTest+Spec.h"

SpecBegin(CASToken)

- (void)testReturnTokenName {
    expect([CASToken stringForType:CASTokenTypeUnknown]).to.equal(@"unknown");
    expect([CASToken stringForType:CASTokenTypeIndent]).to.equal(@"indent");
    expect([CASToken stringForType:CASTokenTypeOutdent]).to.equal(@"outdent");
    expect([CASToken stringForType:CASTokenTypeEOS]).to.equal(@"EOS");
    expect([CASToken stringForType:CASTokenTypeSemiColon]).to.equal(@"semicolon");
    expect([CASToken stringForType:CASTokenTypeCarat]).to.equal(@"carat");
    expect([CASToken stringForType:CASTokenTypeNewline]).to.equal(@"newline");
    expect([CASToken stringForType:CASTokenTypeLeftSquareBrace]).to.equal(@"left square brace");
    expect([CASToken stringForType:CASTokenTypeRightSquareBrace]).to.equal(@"right square brace");
    expect([CASToken stringForType:CASTokenTypeLeftCurlyBrace]).to.equal(@"left curly brace");
    expect([CASToken stringForType:CASTokenTypeRightCurlyBrace]).to.equal(@"right curly brace");
    expect([CASToken stringForType:CASTokenTypeLeftRoundBrace]).to.equal(@"left round brace");
    expect([CASToken stringForType:CASTokenTypeRightRoundBrace]).to.equal(@"right round brace");
    expect([CASToken stringForType:CASTokenTypeColor]).to.equal(@"color");
    expect([CASToken stringForType:CASTokenTypeString]).to.equal(@"string");
    expect([CASToken stringForType:CASTokenTypeUnit]).to.equal(@"unit");
    expect([CASToken stringForType:CASTokenTypeBoolean]).to.equal(@"boolean");
    expect([CASToken stringForType:CASTokenTypeRef]).to.equal(@"ref");
    expect([CASToken stringForType:CASTokenTypeOperator]).to.equal(@"operator");
    expect([CASToken stringForType:CASTokenTypeSpace]).to.equal(@"space");
    expect([CASToken stringForType:CASTokenTypeSelector]).to.equal(@"selector");
}

- (void)testReturnTokenDescriptionWithValue {
    CASToken *token = [CASToken tokenOfType:CASTokenTypeColor];
    token.value = @"#456456";

    expect([token description]).to.equal(@"color #456456");
}

- (void)testReturnTokenDescription {
    CASToken *token = [CASToken tokenOfType:CASTokenTypeColor];
    
    expect([token description]).to.equal(@"color");
}

- (void)testCodingAndDecoding {
    CASToken *tokenNewline = [CASToken tokenOfType:CASTokenTypeNewline];
    CASToken *tokenColor = [CASToken tokenOfType:CASTokenTypeColor];
    tokenColor.value = [UIColor colorWithWhite:0.5f alpha:0.5f];
    CASToken *tokenString = [CASToken tokenOfType:CASTokenTypeString];
    tokenString.value = @"A string";
    
    NSArray *tokensArray = @[tokenColor, tokenNewline, tokenString];
    
    NSData *serizlizedTokensArray = [NSKeyedArchiver archivedDataWithRootObject:tokensArray];
    
    NSArray *tokensArrayDeserialized = [NSKeyedUnarchiver unarchiveObjectWithData:serizlizedTokensArray];
    
    expect(tokensArray).to.equal(tokensArrayDeserialized);
}

SpecEnd
