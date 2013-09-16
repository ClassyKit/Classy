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

it(@"should clean up newlines", ^{
    MODLexer *lexer = [[MODLexer alloc] initWithString:@"hello \r\n world \r"];
    expect(lexer.str).to.equal(@"hello \n world \n");
});

SpecEnd