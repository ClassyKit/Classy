//
//  MODParserSpec.m
//  Mod
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODParser.h"
#import "MODStyleNode.h"
#import "MODToken.h"
#import "UIColor+MODAdditions.h"
#import "MODStyleSelector.h"

@interface MODStyleNode ()
@property (nonatomic, strong) NSMutableArray *styleProperties;
@end

SpecBegin(MODParser)

describe(@"init", ^{

    it(@"should return error if file doesn't exist", ^{
        NSError *error = nil;

        NSArray *styles = [MODParser stylesFromFilePath:@"dummy.txt" error:&error];
        expect(error.domain).to.equal(MODParseErrorDomain);
        expect(error.code).to.equal(MODParseErrorFileContents);

        NSError *underlyingError = error.userInfo[NSUnderlyingErrorKey];
        expect(underlyingError.domain).to.equal(NSCocoaErrorDomain);
        expect(underlyingError.code).to.equal(NSFileReadNoSuchFileError);
        expect(styles).to.beNil();
    });

    it(@"should load file", ^{
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Basic.mod" ofType:nil];
        NSError *error = nil;

        NSArray *styles = [MODParser stylesFromFilePath:filePath error:&error];
        expect(styles).notTo.beNil();
        expect(error).to.beNil();
    });

});

describe(@"selectors", ^{

    it(@"should parse basic", ^{
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Basic.mod" ofType:nil];
        NSArray *styles = [MODParser stylesFromFilePath:filePath error:nil];

        expect(styles.count).to.equal(7);

        MODStyleSelector *selector1 = styles[0];
        expect(selector1.stringValue).to.equal(@"UIView");
        expect(selector1.node).toNot.beNil();

        MODStyleSelector *selector2 = styles[1];
        expect(selector2.stringValue).to.equal(@"UIControl");
        expect(selector2.node).toNot.beNil();

        MODStyleSelector *selector3 = styles[2];
        expect(selector3.stringValue).to.equal(@"UIView");
        expect(selector3.node).toNot.beNil();

        MODStyleSelector *selector4 = styles[3];
        expect(selector4.stringValue).to.equal(@"UIButton");
        expect(selector4.node).notTo.beIdenticalTo(selector3.node);

        MODStyleSelector *selector5 = styles[4];
        expect(selector5.stringValue).to.equal(@"UITabBar");
        expect(selector5.node).notTo.beIdenticalTo(selector3.node);

        MODStyleSelector *selector6 = styles[5];
        expect(selector6.stringValue).to.equal(@"UIView");
        expect(selector6.node).toNot.beNil();

        MODStyleSelector *selector7 = styles[6];
        expect(selector7.stringValue).to.equal(@"UITabBar");
        expect(selector7.node).notTo.beIdenticalTo(selector6.node);
    });

    it(@"should parse complex", ^{
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Complex.mod" ofType:nil];
        NSArray *styles = [MODParser stylesFromFilePath:filePath error:nil];

        expect(styles.count).to.equal(6);

        expect([styles[0] stringValue]).to.equal(@"UIButton[coolness:alot, state:selected].command");
        
        expect([styles[1] stringValue]).to.equal(@"UIButton UIImageView .starImage");

        expect([styles[2] stringValue]).to.equal(@"UIView.bordered");

        expect([styles[3] stringValue]).to.equal(@".panel");

        expect([styles[4] stringValue]).to.equal(@"UISlider");

        expect([styles[5] stringValue]).to.equal(@"UINavigationBar.videoNavBar UIButton[state:highlighted]");
    });

    it(@"should parse without braces", ^{
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Indentation.mod" ofType:nil];
        NSArray *styles = [MODParser stylesFromFilePath:filePath error:nil];

        expect(styles.count).to.equal(6);

        expect([styles[0] stringValue]).to.equal(@"UIButton[state:selected] UIControl");

        expect([styles[1] stringValue]).to.equal(@"UIButton UIImageView .starImage");

        expect([styles[2] stringValue]).to.equal(@"UIView.bordered");

        expect([styles[3] stringValue]).to.equal(@".panel");

        expect([styles[4] stringValue]).to.equal(@"UISlider");

        expect([styles[5] stringValue]).to.equal(@"UINavigationBar.videoNavBar UIButton[state:highlighted]");
    });

    it(@"should parse direct descendant", ^{
        NSError *error = nil;
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Hierarchy.mod" ofType:nil];
        NSArray *styles = [MODParser stylesFromFilePath:filePath error:&error];

        expect(error).to.beNil();
        expect(styles.count).to.equal(4);
        
        expect([styles[0] stringValue]).to.equal(@"UIButton > UIImageView .starImage");

        expect([styles[1] stringValue]).to.equal(@"^UIView > UINavigationBar");

        expect([styles[2] stringValue]).to.equal(@"UIView.bordered > .panel");

        expect([styles[3] stringValue]).to.equal(@"^UIView[state:selected] > UIImageView");
    });

});

describe(@"properties", ^{

    it(@"should parse properties", ^{
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.mod" ofType:nil];
        NSArray *styles = [MODParser stylesFromFilePath:filePath error:nil];

        expect(styles.count).to.equal(5);

        // group 1
        MODStyleNode *node = [styles[0] node];
        expect(node.styleProperties).to.haveCountOf(2);
        expect([node.styleProperties[0] name]).to.equal(@"backgroundColor");
        expect([node.styleProperties[0] values]).to.equal(@[[UIColor mod_colorWithHex:@"#ffffff"]]);
        expect([node.styleProperties[1] name]).to.equal(@"borderInset");
        expect([node.styleProperties[1] values]).to.equal(@[@1]);

        // group 2
        node = [styles[2] node];
        expect(node.styleProperties).to.haveCountOf(2);
        expect([node.styleProperties[0] name]).to.equal(@"fontColor");
        expect([node.styleProperties[0] values]).to.equal(@[[UIColor mod_colorWithHex:@"#ffffff"]]);
        expect([node.styleProperties[1] name]).to.equal(@"borderWidth");
        expect([node.styleProperties[1] values]).to.equal(@[@2]);

        // group 3
        node = [styles[3] node];
        expect(node.styleProperties).to.haveCountOf(3);
        expect([node.styleProperties[0] name]).to.equal(@"fontName");
        expect([node.styleProperties[0] values]).to.equal(@[@"helvetica"]);
        expect([node.styleProperties[1] name]).to.equal(@"size");
        expect([node.styleProperties[1] values]).to.equal((@[@40, @50]));
        expect([node.styleProperties[2] name]).to.equal(@"textColor");
        expect([node.styleProperties[2] values]).to.equal(@[[UIColor mod_colorWithHex:@"#444"]]);
    });

});

SpecEnd