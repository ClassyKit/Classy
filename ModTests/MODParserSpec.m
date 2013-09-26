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
#import "UIColor+MODAdditions.h"

@interface MODParser ()
@property (nonatomic, strong) NSMutableArray *styleGroups;
@end

@interface MODStyleGroup ()
@property (nonatomic, strong) NSMutableArray *selectors;
@property (nonatomic, strong) NSMutableArray *styleProperties;
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
        MODStyleGroup *group = parser.styleGroups[0];
        expect(group.selectors).to.haveCountOf(1);
        expect(group.selectors[0]).to.equal(@"UIView");

        //group 2
        group = parser.styleGroups[1];
        expect(group.selectors).to.haveCountOf(1);
        expect(group.selectors[0]).to.equal(@"UIControl");

        //group 3
        group = parser.styleGroups[2];
        expect(group.selectors).to.haveCountOf(3);
        expect(group.selectors[0]).to.equal(@"UIView");
        expect(group.selectors[1]).to.equal(@"UIButton");
        expect(group.selectors[2]).to.equal(@"UITabBar");

        //group 4
        group = parser.styleGroups[3];
        expect(group.selectors).to.haveCountOf(2);
        expect(group.selectors[0]).to.equal(@"UIView");
        expect(group.selectors[1]).to.equal(@"UITabBar");
    });

    it(@"should parse complex", ^{
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Complex.mod" ofType:nil];
        MODParser *parser = [[MODParser alloc] initWithFilePath:filePath error:nil];
        [parser parse];

        expect(parser.styleGroups.count).to.equal(3);

        //group 1
        MODStyleGroup *group = parser.styleGroups[0];
        expect(group.selectors).to.haveCountOf(1);
        expect(group.selectors[0]).to.equal(@"UIButton:selected UIControl");

        //group 2
        group = parser.styleGroups[1];
        expect(group.selectors).to.haveCountOf(2);
        expect(group.selectors[0]).to.equal(@"UIView.bordered");
        expect(group.selectors[1]).to.equal(@"UIControl.highlighted");

        //group 3
        group = parser.styleGroups[2];
        expect(group.selectors).to.haveCountOf(2);
        expect(group.selectors[0]).to.equal(@"UISlider");
        expect(group.selectors[1]).to.equal(@"UINavigationBar UIButton");
    });

    it(@"should parse without braces", ^{
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Indentation.mod" ofType:nil];
        MODParser *parser = [[MODParser alloc] initWithFilePath:filePath error:nil];
        [parser parse];

        expect(parser.styleGroups.count).to.equal(3);

        //group 1
        MODStyleGroup *group = parser.styleGroups[0];
        expect(group.selectors).to.haveCountOf(1);
        expect(group.selectors[0]).to.equal(@"UIButton:selected UIControl");

        //group 2
        group = parser.styleGroups[1];
        expect(group.selectors).to.haveCountOf(2);
        expect(group.selectors[0]).to.equal(@"UIView.bordered");
        expect(group.selectors[1]).to.equal(@"UIControl.highlighted");

        //group 3
        group = parser.styleGroups[2];
        expect(group.selectors).to.haveCountOf(2);
        expect(group.selectors[0]).to.equal(@"UISlider");
        expect(group.selectors[1]).to.equal(@"UINavigationBar UIButton");
    });

});

describe(@"properties", ^{

    it(@"should parse properties", ^{
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.mod" ofType:nil];
        MODParser *parser = [[MODParser alloc] initWithFilePath:filePath error:nil];
        [parser parse];

        expect(parser.styleGroups.count).to.equal(3);

        //group 1
        MODStyleGroup *group = parser.styleGroups[0];
        expect(group.styleProperties).to.haveCountOf(2);
        expect([group.styleProperties[0] name]).to.equal(@"background-color");
        expect([group.styleProperties[0] values]).to.equal(@[[UIColor mod_colorWithHex:@"#ffffff"]]);
        expect([group.styleProperties[1] name]).to.equal(@"border-inset");
        expect([group.styleProperties[1] values]).to.equal(@[@1]);

        //group 2
        group = parser.styleGroups[1];
        expect(group.styleProperties).to.haveCountOf(2);
        expect([group.styleProperties[0] name]).to.equal(@"font-color");
        expect([group.styleProperties[0] values]).to.equal(@[[UIColor mod_colorWithHex:@"#ffffff"]]);
        expect([group.styleProperties[1] name]).to.equal(@"border-width");
        expect([group.styleProperties[1] values]).to.equal(@[@2]);

        //group 3
        group = parser.styleGroups[2];
        expect(group.styleProperties).to.haveCountOf(3);
        expect([group.styleProperties[0] name]).to.equal(@"font-name");
        expect([group.styleProperties[0] values]).to.equal(@[@"helvetica"]);
        expect([group.styleProperties[1] name]).to.equal(@"size");
        expect([group.styleProperties[1] values]).to.equal((@[@40, @50]));
        expect([group.styleProperties[2] name]).to.equal(@"text-color");
        expect([group.styleProperties[2] values]).to.equal(@[[UIColor mod_colorWithHex:@"#444"]]);
    });

});

SpecEnd