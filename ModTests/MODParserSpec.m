//
//  MODParserSpec.m
//  Mod
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODParser.h"
#import "MODStyleGroup.h"
#import "MODToken.h"

@interface MODParser ()
@property (nonatomic, strong) NSMutableArray *styleGroups;
@end

@interface MODStyleGroup ()
@property (nonatomic, strong) NSMutableArray *selectors;
@end

SpecBegin(MODParser)

describe(@"init", ^{

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
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Basic.mod" ofType:nil];
        NSError *error = nil;
        MODParser *parser = [[MODParser alloc] initWithFilePath:filePath error:&error];
        expect(parser).notTo.beNil();
        expect(error).to.beNil();
    });

});

describe(@"selectors", ^{

    it(@"should parse basic", ^{
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Basic.mod" ofType:nil];
        MODParser *parser = [[MODParser alloc] initWithFilePath:filePath error:nil];
        [parser parse];

        expect(parser.styleGroups.count).to.equal(4);

        //group 1
        expect([parser.styleGroups[0] selectors]).to.haveCountOf(1);
        MODToken *selector = [parser.styleGroups[0] selectors][0];
        expect(selector).to.equal(@"UIView");

        //group 2
        expect([parser.styleGroups[1] selectors]).to.haveCountOf(1);
        selector = [parser.styleGroups[1] selectors][0];
        expect(selector).to.equal(@"UIControl");

        //group 3
        expect([parser.styleGroups[2] selectors]).to.haveCountOf(3);
        selector = [parser.styleGroups[2] selectors][0];
        expect(selector).to.equal(@"UIView");
        selector = [parser.styleGroups[2] selectors][1];
        expect(selector).to.equal(@"UIButton");
        selector = [parser.styleGroups[2] selectors][2];
        expect(selector).to.equal(@"UITabBar");

        //group 4
        expect([parser.styleGroups[3] selectors]).to.haveCountOf(2);
        selector = [parser.styleGroups[3] selectors][0];
        expect(selector).to.equal(@"UIView");
        selector = [parser.styleGroups[3] selectors][1];
        expect(selector).to.equal(@"UITabBar");
    });

    it(@"should parse complex", ^{
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Complex.mod" ofType:nil];
        MODParser *parser = [[MODParser alloc] initWithFilePath:filePath error:nil];
        [parser parse];

        expect(parser.styleGroups.count).to.equal(3);

        //group 1
        expect([parser.styleGroups[0] selectors]).to.haveCountOf(1);
        MODToken *selector = [parser.styleGroups[0] selectors][0];
        expect(selector).to.equal(@"UIButton:selected UIControl");

        //group 2
        expect([parser.styleGroups[1] selectors]).to.haveCountOf(2);
        selector = [parser.styleGroups[1] selectors][0];
        expect(selector).to.equal(@"UIView.bordered");
        selector = [parser.styleGroups[1] selectors][1];
        expect(selector).to.equal(@"UIControl.highlighted");

        //group 3
        expect([parser.styleGroups[2] selectors]).to.haveCountOf(2);
        selector = [parser.styleGroups[2] selectors][0];
        expect(selector).to.equal(@"UISlider");
        selector = [parser.styleGroups[2] selectors][1];
        expect(selector).to.equal(@"UINavigationBar UIButton");
    });

});

SpecEnd