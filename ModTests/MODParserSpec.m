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
@property (nonatomic, strong) NSMutableArray *selectors;
@property (nonatomic, strong) NSMutableArray *styleProperties;
@end

@interface MODStyleSelector ()
@property (nonatomic, strong, readwrite) NSMutableArray *parentSelectors;
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
        expect(selector1.string).to.equal(@"UIView");
        expect(selector1.type).to.equal(MODStyleSelectorTypeViewClass);
        expect(selector1.node).toNot.beNil();

        MODStyleSelector *selector2 = styles[1];
        expect(selector2.string).to.equal(@"UIControl");
        expect(selector2.type).to.equal(MODStyleSelectorTypeViewClass);
        expect(selector2.node).toNot.beNil();

        MODStyleSelector *selector3 = styles[2];
        expect(selector3.string).to.equal(@"UIView");
        expect(selector3.type).to.equal(MODStyleSelectorTypeViewClass);
        expect(selector3.node).toNot.beNil();

        MODStyleSelector *selector4 = styles[3];
        expect(selector4.string).to.equal(@"UIButton");
        expect(selector4.type).to.equal(MODStyleSelectorTypeViewClass);
        expect(selector4.node).to.beIdenticalTo(selector3.node);

        MODStyleSelector *selector5 = styles[4];
        expect(selector5.string).to.equal(@"UITabBar");
        expect(selector5.type).to.equal(MODStyleSelectorTypeViewClass);
        expect(selector5.node).to.beIdenticalTo(selector3.node);

        MODStyleSelector *selector6 = styles[5];
        expect(selector6.string).to.equal(@"UIView");
        expect(selector6.type).to.equal(MODStyleSelectorTypeViewClass);

        MODStyleSelector *selector7 = styles[6];
        expect(selector7.string).to.equal(@"UITabBar");
        expect(selector7.type).to.equal(MODStyleSelectorTypeViewClass);
        expect(selector7.node).to.beIdenticalTo(selector6.node);
    });

    it(@"should parse complex", ^{
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Complex.mod" ofType:nil];
        NSArray *styles = [MODParser stylesFromFilePath:filePath error:nil];

        expect(styles.count).to.equal(7);

        MODStyleSelector *selector1 = styles[0];
        expect(selector1.string).to.equal(@"UIButton.command:selected");
        expect(selector1.node).toNot.beNil();
        expect(selector1.type).to.equal((MODStyleSelectorTypeViewClass | MODStyleSelectorTypePseudo | MODStyleSelectorTypeStyleClass));
        expect(selector1.viewClass).to.equal(UIButton.class);
        expect(selector1.styleClass).to.equal(@"command");
        expect(selector1.pseudo).to.equal(@"selected");
        expect(selector1.parentSelectors).to.haveCountOf(0);

        MODStyleSelector *selector2 = styles[1];
        expect(selector2.string).to.equal(@"UIButton UIImageView .starImage");
        expect(selector2.node).to.beIdenticalTo(selector1.node);
        expect(selector2.type).to.equal(MODStyleSelectorTypeStyleClass);
        expect(selector2.viewClass).to.beNil();
        expect(selector2.styleClass).to.equal(@"starImage");
        expect(selector2.pseudo).to.beNil();
        expect(selector2.parentSelectors).to.haveCountOf(2);

        MODStyleSelector *parentSelector = selector2.parentSelectors[1];
        expect(parentSelector.viewClass).to.equal(UIButton.class);
        expect(parentSelector.styleClass).to.beNil();
        expect(parentSelector.pseudo).to.beNil();

        parentSelector = selector2.parentSelectors[0];
        expect(parentSelector.viewClass).to.equal(UIImageView.class);
        expect(parentSelector.styleClass).to.beNil();
        expect(parentSelector.pseudo).to.beNil();

        MODStyleSelector *selector3 = styles[2];
        expect(selector3.string).to.equal(@"UIView.bordered");
        expect(selector3.node).toNot.beNil();
        expect(selector3.type).to.equal((MODStyleSelectorTypeViewClass | MODStyleSelectorTypeStyleClass));
        expect(selector3.viewClass).to.equal(UIView.class);
        expect(selector3.styleClass).to.equal(@"bordered");
        expect(selector3.pseudo).to.beNil();
        expect(selector3.parentSelectors).to.haveCountOf(0);

        MODStyleSelector *selector4 = styles[3];
        expect(selector4.string).to.equal(@".panel");
        expect(selector4.node).to.beIdenticalTo(selector3.node);
        expect(selector4.type).to.equal((MODStyleSelectorTypeStyleClass));
        expect(selector4.viewClass).to.beNil();
        expect(selector4.styleClass).to.equal(@"panel");
        expect(selector4.pseudo).to.beNil();
        expect(selector4.parentSelectors).to.haveCountOf(0);

        MODStyleSelector *selector5 = styles[4];
        expect(selector5.string).to.equal(@"UISlider");
        expect(selector5.node).toNot.beNil();
        expect(selector5.type).to.equal((MODStyleSelectorTypeViewClass));
        expect(selector5.viewClass).to.equal(UISlider.class);
        expect(selector5.styleClass).to.beNil();
        expect(selector5.pseudo).to.beNil();
        expect(selector5.parentSelectors).to.haveCountOf(0);

        MODStyleSelector *selector6 = styles[5];
        expect(selector6.string).to.equal(@":selected");
        expect(selector6.node).to.beIdenticalTo(selector5.node);
        expect(selector6.type).to.equal((MODStyleSelectorTypePseudo));
        expect(selector6.viewClass).to.beNil();
        expect(selector6.styleClass).to.beNil();
        expect(selector6.pseudo).to.equal(@"selected");
        expect(selector6.parentSelectors).to.haveCountOf(0);

        MODStyleSelector *selector7 = styles[6];
        expect(selector7.string).to.equal(@"UINavigationBar.videoNavBar UIButton :highlighted");
        expect(selector7.node).to.beIdenticalTo(selector6.node);
        expect(selector7.type).to.equal((MODStyleSelectorTypePseudo));
        expect(selector7.viewClass).to.beNil();
        expect(selector7.styleClass).to.beNil();
        expect(selector7.parentSelectors).to.haveCountOf(2);

        parentSelector = selector7.parentSelectors[1];
        expect(parentSelector.viewClass).to.equal(UINavigationBar.class);
        expect(parentSelector.styleClass).to.equal(@"videoNavBar");
        expect(parentSelector.pseudo).to.beNil();

        parentSelector = selector7.parentSelectors[0];
        expect(parentSelector.viewClass).to.equal(UIButton.class);
        expect(parentSelector.styleClass).to.beNil();
        expect(parentSelector.pseudo).to.beNil();
    });

    it(@"should parse without braces", ^{
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Indentation.mod" ofType:nil];
        NSArray *styles = [MODParser stylesFromFilePath:filePath error:nil];

        expect(styles.count).to.equal(7);


        MODStyleSelector *selector1 = styles[0];
        expect(selector1.string).to.equal(@"UIButton:selected UIControl");
        expect(selector1.node).toNot.beNil();
        expect(selector1.type).to.equal(MODStyleSelectorTypeViewClass);
        expect(selector1.viewClass).to.equal(UIControl.class);
        expect(selector1.styleClass).to.beNil();
        expect(selector1.pseudo).to.beNil();
        expect(selector1.parentSelectors).to.haveCountOf(1);

        MODStyleSelector *parentSelector = selector1.parentSelectors[0];
        expect(parentSelector.viewClass).to.equal(UIButton.class);
        expect(parentSelector.styleClass).to.beNil();
        expect(parentSelector.pseudo).to.equal(@"selected");

        MODStyleSelector *selector2 = styles[1];
        expect(selector2.string).to.equal(@"UIButton UIImageView .starImage");
        expect(selector2.node).to.beIdenticalTo(selector1.node);
        expect(selector2.type).to.equal(MODStyleSelectorTypeStyleClass);
        expect(selector2.viewClass).to.beNil();
        expect(selector2.styleClass).to.equal(@"starImage");
        expect(selector2.pseudo).to.beNil();
        expect(selector2.parentSelectors).to.haveCountOf(2);

        parentSelector = selector2.parentSelectors[1];
        expect(parentSelector.viewClass).to.equal(UIButton.class);
        expect(parentSelector.styleClass).to.beNil();
        expect(parentSelector.pseudo).to.beNil();

        parentSelector = selector2.parentSelectors[0];
        expect(parentSelector.viewClass).to.equal(UIImageView.class);
        expect(parentSelector.styleClass).to.beNil();
        expect(parentSelector.pseudo).to.beNil();

        MODStyleSelector *selector3 = styles[2];
        expect(selector3.string).to.equal(@"UIView.bordered");
        expect(selector3.node).toNot.beNil();
        expect(selector3.type).to.equal((MODStyleSelectorTypeViewClass | MODStyleSelectorTypeStyleClass));
        expect(selector3.viewClass).to.equal(UIView.class);
        expect(selector3.styleClass).to.equal(@"bordered");
        expect(selector3.pseudo).to.beNil();
        expect(selector3.parentSelectors).to.haveCountOf(0);

        MODStyleSelector *selector4 = styles[3];
        expect(selector4.string).to.equal(@".panel");
        expect(selector4.node).to.beIdenticalTo(selector3.node);
        expect(selector4.type).to.equal((MODStyleSelectorTypeStyleClass));
        expect(selector4.viewClass).to.beNil();
        expect(selector4.styleClass).to.equal(@"panel");
        expect(selector4.pseudo).to.beNil();
        expect(selector4.parentSelectors).to.haveCountOf(0);

        MODStyleSelector *selector5 = styles[4];
        expect(selector5.string).to.equal(@"UISlider");
        expect(selector5.node).toNot.beNil();
        expect(selector5.type).to.equal((MODStyleSelectorTypeViewClass));
        expect(selector5.viewClass).to.equal(UISlider.class);
        expect(selector5.styleClass).to.beNil();
        expect(selector5.pseudo).to.beNil();
        expect(selector5.parentSelectors).to.haveCountOf(0);

        MODStyleSelector *selector6 = styles[5];
        expect(selector6.string).to.equal(@":selected");
        expect(selector6.node).to.beIdenticalTo(selector5.node);
        expect(selector6.type).to.equal((MODStyleSelectorTypePseudo));
        expect(selector6.viewClass).to.beNil();
        expect(selector6.styleClass).to.beNil();
        expect(selector6.pseudo).to.equal(@"selected");
        expect(selector6.parentSelectors).to.haveCountOf(0);

        MODStyleSelector *selector7 = styles[6];
        expect(selector7.string).to.equal(@"UINavigationBar.videoNavBar UIButton :highlighted");
        expect(selector7.node).to.beIdenticalTo(selector6.node);
        expect(selector7.type).to.equal((MODStyleSelectorTypePseudo));
        expect(selector7.viewClass).to.beNil();
        expect(selector7.styleClass).to.beNil();
        expect(selector7.parentSelectors).to.haveCountOf(2);

        parentSelector = selector7.parentSelectors[1];
        expect(parentSelector.viewClass).to.equal(UINavigationBar.class);
        expect(parentSelector.styleClass).to.equal(@"videoNavBar");
        expect(parentSelector.pseudo).to.beNil();

        parentSelector = selector7.parentSelectors[0];
        expect(parentSelector.viewClass).to.equal(UIButton.class);
        expect(parentSelector.styleClass).to.beNil();
        expect(parentSelector.pseudo).to.beNil();
    });

});

describe(@"properties", ^{

    it(@"should parse properties", ^{
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.mod" ofType:nil];
        NSArray *styles = [MODParser stylesFromFilePath:filePath error:nil];

        expect(styles.count).to.equal(5);

        //group 1
        MODStyleNode *node = [styles[0] node];
        expect(node.styleProperties).to.haveCountOf(2);
        expect([node.styleProperties[0] name]).to.equal(@"background-color");
        expect([node.styleProperties[0] values]).to.equal(@[[UIColor mod_colorWithHex:@"#ffffff"]]);
        expect([node.styleProperties[1] name]).to.equal(@"border-inset");
        expect([node.styleProperties[1] values]).to.equal(@[@1]);

        //group 2
        node = [styles[2] node];
        expect(node.styleProperties).to.haveCountOf(2);
        expect([node.styleProperties[0] name]).to.equal(@"font-color");
        expect([node.styleProperties[0] values]).to.equal(@[[UIColor mod_colorWithHex:@"#ffffff"]]);
        expect([node.styleProperties[1] name]).to.equal(@"border-width");
        expect([node.styleProperties[1] values]).to.equal(@[@2]);

        //group 3
        node = [styles[3] node];
        expect(node.styleProperties).to.haveCountOf(3);
        expect([node.styleProperties[0] name]).to.equal(@"font-name");
        expect([node.styleProperties[0] values]).to.equal(@[@"helvetica"]);
        expect([node.styleProperties[1] name]).to.equal(@"size");
        expect([node.styleProperties[1] values]).to.equal((@[@40, @50]));
        expect([node.styleProperties[2] name]).to.equal(@"text-color");
        expect([node.styleProperties[2] values]).to.equal(@[[UIColor mod_colorWithHex:@"#444"]]);
    });

});

SpecEnd