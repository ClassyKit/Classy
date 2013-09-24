//
//  MODTokenSpec.m
//  Mod
//
//  Created by Jonas Budelmann on 24/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODToken.h"

SpecBegin(MODToken)

it(@"should return token name", ^{
    expect([MODToken stringForType:MODTokenTypeIndent]).to.equal(@"indent");
    expect([MODToken stringForType:MODTokenTypeOutdent]).to.equal(@"outdent");
    expect([MODToken stringForType:MODTokenTypeEOS]).to.equal(@"EOS");
    expect([MODToken stringForType:MODTokenTypeSemiColon]).to.equal(@"semicolon");
    expect([MODToken stringForType:MODTokenTypeNewline]).to.equal(@"newline");
    expect([MODToken stringForType:MODTokenTypeBrace]).to.equal(@"brace");
    expect([MODToken stringForType:MODTokenTypeColor]).to.equal(@"color");
    expect([MODToken stringForType:MODTokenTypeString]).to.equal(@"string");
    expect([MODToken stringForType:MODTokenTypeUnit]).to.equal(@"unit");
    expect([MODToken stringForType:MODTokenTypeBoolean]).to.equal(@"boolean");
    expect([MODToken stringForType:MODTokenTypeRef]).to.equal(@"ref");
    expect([MODToken stringForType:MODTokenTypeSpace]).to.equal(@"space");
    expect([MODToken stringForType:MODTokenTypeSelector]).to.equal(@"selector");
});

it(@"should return token description", ^{
    MODToken *token = [MODToken tokenOfType:MODTokenTypeBrace];
    token.value = @"{";

    expect([token description]).to.equal(@"brace:{");
});

SpecEnd