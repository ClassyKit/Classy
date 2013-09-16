//
//  MODParserSpec.m
//  Mod
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODParser.h"

SpecBegin(MODParser)

it(@"should return error if file doesn't exist", ^{
    NSError *error = nil;

    MODParser *parser = [[MODParser alloc] initWithFilePath:@"dummy.txt" error:&error];
    expect(error.domain).to.equal(MODParserErrorDomain);
    expect(error.code).to.equal(MODParserErrorFileContents);

    NSError *underlyingError = error.userInfo[NSUnderlyingErrorKey];
    expect(underlyingError.domain).to.equal(NSCocoaErrorDomain);
    expect(underlyingError.code).to.equal(NSFileReadNoSuchFileError);
    expect(parser).to.beNil();
});

it(@"should load file", ^{
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIView-Basic.mod" ofType:nil];
    NSError *error = nil;
    MODParser *parser = [[MODParser alloc] initWithFilePath:filePath error:&error];
    expect(parser).notTo.beNil();
    expect(error).to.beNil();
});

SpecEnd