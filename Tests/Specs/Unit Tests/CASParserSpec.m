//
//  CASParserSpec.m
//  Classy
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASParser.h"
#import "XCTest+Spec.h"
#import "CASStyleNode.h"
#import "CASToken.h"
#import "UIColor+CASAdditions.h"
#import "CASStyleSelector.h"
#import "UIDevice+CASMockDevice.h"

SpecBegin(CASParser) {
    UIDevice *mockDevice;
}

- (void)setUp {
    mockDevice = mock(UIDevice.class);
    [UIDevice setMockDevice:mockDevice];
}

- (void)tearDown {
    [UIDevice setMockDevice:nil];
}

- (void)testErrorWhenNoFile {
    NSError *error = nil;

    NSArray *styles = [CASParser parserFromFilePath:@"dummy.txt" variables:nil error:&error].styleNodes;
    expect(error.domain).to.equal(CASParseErrorDomain);
    expect(error.code).to.equal(CASParseErrorFileContents);

    NSError *underlyingError = error.userInfo[NSUnderlyingErrorKey];
    expect(underlyingError.domain).to.equal(NSCocoaErrorDomain);
    expect(underlyingError.code).to.equal(NSFileReadNoSuchFileError);
    expect(styles).to.beNil();
}

- (void)testLoadFile {
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Messy.cas" ofType:nil];
    NSError *error = nil;

    NSArray *styles = [CASParser parserFromFilePath:filePath variables:nil error:&error].styleNodes;
    expect(styles).notTo.beNil();
    expect(error).to.beNil();
}

- (void)testParseBasic {
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Messy.cas" ofType:nil];
    NSArray *styles = [CASParser parserFromFilePath:filePath variables:nil error:nil].styleNodes;

    expect(styles.count).to.equal(7);

    expect([styles[0] styleSelector].stringValue).to.equal(@"UIView");
    expect([styles[1] styleSelector].stringValue).to.equal(@"UIControl");
    expect([styles[2] styleSelector].stringValue).to.equal(@"UIView");
    expect([styles[3] styleSelector].stringValue).to.equal(@"UIButton");
    expect([styles[4] styleSelector].stringValue).to.equal(@"UITabBar");
    expect([styles[5] styleSelector].stringValue).to.equal(@"UIView");
    expect([styles[6] styleSelector].stringValue).to.equal(@"UITabBar");
}

- (void)testParseComplex {
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Complex.cas" ofType:nil];
    NSArray *styles = [CASParser parserFromFilePath:filePath variables:nil error:nil].styleNodes;

    expect(styles.count).to.equal(6);

    expect([styles[0] styleSelector].stringValue).to.equal(@"UIButton[coolness:alot, state:selected].command");
    expect([styles[1] styleSelector].stringValue).to.equal(@"UIButton UIImageView.starImage");
    expect([styles[2] styleSelector].stringValue).to.equal(@"UIView.bordered");
    expect([styles[3] styleSelector].stringValue).to.equal(@"UIView.panel");
    expect([styles[4] styleSelector].stringValue).to.equal(@"UISlider");
    expect([styles[5] styleSelector].stringValue).to.equal(@"UINavigationBar.videoNavBar UIButton[state:highlighted]");
}

- (void)testParseWithoutBraces {
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Indentation.cas" ofType:nil];
    NSArray *styles = [CASParser parserFromFilePath:filePath variables:nil error:nil].styleNodes;

    expect(styles.count).to.equal(6);

    expect([styles[0] styleSelector].stringValue).to.equal(@"UIButton UIControl");
    expect([styles[0] styleProperties]).to.haveCountOf(2);
    expect([styles[0] styleSelector].precedence).to.equal(6);

    expect([styles[1] styleSelector].stringValue).to.equal(@"UIButton UIImageView.starImage");
    expect([styles[1] styleProperties]).to.haveCountOf(2);
    expect([styles[1] styleSelector].precedence).to.equal(3006);

    expect([styles[2] styleSelector].stringValue).to.equal(@"UIView.bordered");
    expect([styles[2] styleProperties]).to.haveCountOf(3);
    expect([styles[2] styleSelector].precedence).to.equal(3004);

    expect([styles[3] styleSelector].stringValue).to.equal(@"UIView.panel");
    expect([styles[3] styleProperties]).to.haveCountOf(3);
    expect([styles[3] styleSelector].precedence).to.equal(3004);

    expect([styles[4] styleSelector].stringValue).to.equal(@"UISlider");
    expect([styles[4] styleProperties]).to.haveCountOf(4);
    expect([styles[4] styleSelector].precedence).to.equal(4);

    expect([styles[5] styleSelector].stringValue).to.equal(@"UINavigationBar.videoNavBar UIButton");
    expect([styles[5] styleProperties]).to.haveCountOf(4);
    expect([styles[5] styleSelector].precedence).to.equal(1006);
}

- (void)testParseDirectDescendant {
    NSError *error = nil;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Hierarchy.cas" ofType:nil];
    NSArray *styles = [CASParser parserFromFilePath:filePath variables:nil error:&error].styleNodes;

    expect(error).to.beNil();
    expect(styles.count).to.equal(4);

    expect([styles[0] styleSelector].stringValue).to.equal(@"UIButton > UIImageView.starImage");
    expect([styles[0] styleSelector].precedence).to.equal(3006);
    expect([styles[0] styleProperties]).to.haveCountOf(1);

    expect([styles[1] styleSelector].stringValue).to.equal(@"^UIView > UINavigationBar");
    expect([styles[1] styleSelector].precedence).to.equal(5);
    expect([styles[1] styleProperties]).to.haveCountOf(2);

    expect([styles[2] styleSelector].stringValue).to.equal(@"UIView.bordered > UIView.panel");
    expect([styles[2] styleSelector].parentSelector).notTo.beNil();
    expect([styles[2] styleSelector].precedence).to.equal(4006);
    expect([styles[2] styleProperties]).to.haveCountOf(3);

    expect([styles[3] styleSelector].stringValue).to.equal(@"^UIView[state:selected] > UIImageView");
    expect([styles[3] styleSelector].precedence).to.equal(5);
    expect([styles[3] styleProperties]).to.haveCountOf(4);
}

- (void)testParseNestedSelectors {
    NSError *error = nil;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Nested.cas" ofType:nil];
    NSArray *styles = [CASParser parserFromFilePath:filePath variables:nil error:&error].styleNodes;

    expect(error).to.beNil();

    expect(styles.count).to.equal(14);
    expect([styles[0] styleSelector].stringValue).to.equal(@"UIButton");
    expect([styles[1] styleSelector].stringValue).to.equal(@"UIButton > UIControl");
    expect([styles[2] styleSelector].stringValue).to.equal(@"UIButton UISlider");
    expect([styles[3] styleSelector].stringValue).to.equal(@"UIView");
    expect([styles[4] styleSelector].stringValue).to.equal(@"UIView UINavigationBar");
    expect([styles[5] styleSelector].stringValue).to.equal(@"UIView UINavigationBar > UIView");
    expect([styles[6] styleSelector].stringValue).to.equal(@"UITabBar.nice");
    expect([styles[7] styleSelector].stringValue).to.equal(@"UISegmentedControl.nice");
    expect([styles[8] styleSelector].stringValue).to.equal(@"UITabBar.nice UITextField");
    expect([styles[9] styleSelector].stringValue).to.equal(@"UISegmentedControl.nice UITextField");
    expect([styles[10] styleSelector].stringValue).to.equal(@"UITabBar.nice UITextField.nicer");
    expect([styles[11] styleSelector].stringValue).to.equal(@"UISegmentedControl.nice UITextField.nicer");
    expect([styles[12] styleSelector].stringValue).to.equal(@"UITableViewCell");
    expect([styles[13] styleSelector].stringValue).to.equal(@"UITableViewCell UILabel");

    // node 1
    CASStyleNode *node = styles[0];
    expect(node.styleProperties).to.haveCountOf(2);
    expect([node.styleProperties[0] name]).to.equal(@"backgroundColor");
    expect([node.styleProperties[0] values]).to.equal(@[[UIColor cas_colorWithHex:@"#ffffff"]]);
    expect([node.styleProperties[1] name]).to.equal(@"borderWidth");
    expect([node.styleProperties[1] values]).to.equal(@[@1]);

    // node 2
    node = styles[1];
    expect(node.styleProperties).to.haveCountOf(1);
    expect([node.styleProperties[0] name]).to.equal(@"amazing");
    expect([node.styleProperties[0] values]).to.equal(@[@23]);

    // node 3
    node = styles[2];
    expect(node.styleProperties).to.haveCountOf(1);
    expect([node.styleProperties[0] name]).to.equal(@"another");
    expect([node.styleProperties[0] values]).to.equal((@[@34]));

    // node 4
    node = styles[3];
    expect(node.styleProperties).to.haveCountOf(1);
    expect([node.styleProperties[0] name]).to.equal(@"borderColor");
    expect([node.styleProperties[0] values]).to.equal((@[[UIColor cas_colorWithHex:@"#ddd"]]));

    // node 5
    node = styles[4];
    expect(node.styleProperties).to.haveCountOf(0);

    // node 6
    node = styles[5];
    expect(node.styleProperties).to.haveCountOf(1);
    expect([node.styleProperties[0] name]).to.equal(@"backgroundColor");
    expect([node.styleProperties[0] values]).to.equal((@[[UIColor cas_colorWithHex:@"#eee"]]));

    // node 7
    node = styles[6];
    expect(node.styleProperties).to.haveCountOf(0);

    // node 8
    node = styles[7];
    expect(node.styleProperties).to.haveCountOf(0);

    // node 9
    node = styles[8];
    expect(node.styleProperties).to.haveCountOf(1);
    expect([node.styleProperties[0] name]).to.equal(@"borderWidth");
    expect([node.styleProperties[0] values]).to.equal(@[@2]);

    // node 10
    node = styles[9];
    expect(node.styleProperties).to.haveCountOf(1);
    expect([node.styleProperties[0] name]).to.equal(@"borderWidth");
    expect([node.styleProperties[0] values]).to.equal(@[@2]);

    // node 11
    node = styles[10];
    expect(node.styleProperties).to.haveCountOf(1);
    expect([node.styleProperties[0] name]).to.equal(@"borderWidth");
    expect([node.styleProperties[0] values]).to.equal(@[@3]);

    // node 12
    node = styles[11];
    expect(node.styleProperties).to.haveCountOf(1);
    expect([node.styleProperties[0] name]).to.equal(@"borderWidth");
    expect([node.styleProperties[0] values]).to.equal(@[@3]);

    // node 13
    node = styles[12];
    expect(node.styleProperties).to.haveCountOf(2);
    expect([node.styleProperties[0] name]).to.equal(@"normalBgColor");
    expect([node.styleProperties[0] values]).to.equal(@[@"$blue-color"]);

    expect([node.styleProperties[1] name]).to.equal(@"selectedBgColor");
    expect([node.styleProperties[1] values]).to.equal(@[@"$light-blue-color"]);

    // node 14
    node = styles[13];
    expect(node.styleProperties).to.haveCountOf(2);
    expect([node.styleProperties[0] name]).to.equal(@"font");
    expect([node.styleProperties[0] values]).to.equal((@[@"HelveticaNeue", @14]));
    expect([node.styleProperties[1] name]).to.equal(@"textAlignment");
    expect([node.styleProperties[1] values]).to.equal((@[@"center"]));
}

- (void)testParseProperties {
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.cas" ofType:nil];
    NSArray *styles = [CASParser parserFromFilePath:filePath variables:nil error:nil].styleNodes;

    expect(styles.count).to.equal(5);

    // node 1
    CASStyleNode *node = styles[0];
    expect(node.styleProperties).to.haveCountOf(2);
    expect([node.styleProperties[0] name]).to.equal(@"backgroundColor");
    expect([node.styleProperties[0] values]).to.equal(@[[UIColor cas_colorWithHex:@"#ffffff"]]);
    expect([node.styleProperties[1] name]).to.equal(@"borderInset");
    expect([node.styleProperties[1] values]).to.equal(@[@1]);

    // node 2
    node = styles[2];
    expect(node.styleProperties).to.haveCountOf(2);
    expect([node.styleProperties[0] name]).to.equal(@"fontColor");
    expect([node.styleProperties[0] values]).to.equal(@[[UIColor cas_colorWithHex:@"#ffffff"]]);
    expect([node.styleProperties[1] name]).to.equal(@"borderWidth");
    expect([node.styleProperties[1] values]).to.equal(@[@2]);

    // node 3
    node = styles[3];
    expect(node.styleProperties).to.haveCountOf(3);
    expect([node.styleProperties[0] name]).to.equal(@"fontName");
    expect([node.styleProperties[0] values]).to.equal(@[@"helvetica"]);
    expect([node.styleProperties[1] name]).to.equal(@"size");
    expect([node.styleProperties[1] values]).to.equal((@[@40, @50]));
    expect([node.styleProperties[2] name]).to.equal(@"textColor");
    expect([node.styleProperties[2] values]).to.equal(@[[UIColor cas_colorWithHex:@"#444"]]);
}

- (void)testParsePropertyArguments {
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Args.cas" ofType:nil];
    NSArray *styles = [CASParser parserFromFilePath:filePath variables:nil error:nil].styleNodes;

    expect(styles.count).to.equal(1);
    CASStyleNode *node = styles[0];
    expect(node.styleProperties).to.haveCountOf(3);

    expect([node.styleProperties[0] name]).to.equal(@"backgroundColor");
    expect([node.styleProperties[0] values]).to.equal(@[[UIColor cas_colorWithHex:@"#ffffff"]]);
    expect([node.styleProperties[0] arguments]).to.equal(@{ @"state" : @"selected" });
    expect([node.styleProperties[1] name]).to.equal(@"fontName");
    expect([node.styleProperties[1] values]).to.equal(@[@"helvetica"]);
    expect([node.styleProperties[1] arguments]).to.equal(@{ @"state" : @"highlighted" });
    expect([node.styleProperties[2] name]).to.equal(@"fontSize");
    expect([node.styleProperties[2] values]).to.equal(@[@14]);
    expect([node.styleProperties[2] arguments]).to.equal(@{ @"state" : @"disabled" });
}

- (void)testParseNestedProperties {
    NSError *error = nil;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Nested.cas" ofType:nil];
    NSArray *styles = [CASParser parserFromFilePath:filePath variables:nil error:&error].styleNodes;
    expect(error).to.beNil();

    expect(styles).to.haveCountOf(3);

    // node 1
    CASStyleNode *node = styles[0];
    expect(node.styleSelector.stringValue).to.equal(@"UIButton");
    expect(node.styleProperties).to.haveCountOf(3);
    expect([node.styleProperties[0] name]).to.equal(@"backgroundColor");
    expect([node.styleProperties[1] name]).to.equal(@"borderWidth");

    CASStyleProperty *embed = node.styleProperties[2];
    expect(embed.name).to.equal(@"embed");
    expect(embed.childStyleProperties).to.haveCountOf(4);
    expect([embed.childStyleProperties[0] name]).to.equal(@"font");
    expect([embed.childStyleProperties[0] values]).to.equal((@[@"arial", @15]));
    expect([embed.childStyleProperties[2] name]).to.equal(@"kern");
    expect([embed.childStyleProperties[2] values]).to.equal(@[@5]);
    expect([embed.childStyleProperties[3] name]).to.equal(@"stuff");
    expect([embed.childStyleProperties[3] values]).to.equal(@[@"1 more thing"]);

    CASStyleProperty *paragraphStyle = embed.childStyleProperties[1];
    expect(paragraphStyle.name).to.equal(@"paragraphStyle");
    expect(paragraphStyle.childStyleProperties).to.haveCountOf(2);
    expect([paragraphStyle.childStyleProperties[0] name]).to.equal(@"maximumLineHeight");
    expect([paragraphStyle.childStyleProperties[0] values]).to.equal(@[@2]);
    expect([paragraphStyle.childStyleProperties[1] name]).to.equal(@"minimumLineHeight");
    expect([paragraphStyle.childStyleProperties[1] values]).to.equal(@[@4]);

    // node 2
    node = styles[1];
    expect(node.styleSelector.stringValue).to.equal(@"UIButton > UINavigationBar");
    expect(node.styleProperties).to.haveCountOf(1);
    expect([node.styleProperties[0] name]).to.equal(@"amazing");

    // node 3
    node = styles[2];
    expect(node.styleSelector.stringValue).to.equal(@"UIButton UISlider");
    expect(node.styleProperties).to.haveCountOf(1);
    expect([node.styleProperties[0] name]).to.equal(@"another");
}

- (void)testMediaQueries {
    NSError *error = nil;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Media-Queries.cas" ofType:nil];
    NSArray *styles = [CASParser parserFromFilePath:filePath variables:nil error:&error].styleNodes;
    expect(error).to.beNil();

    expect(styles).to.haveCountOf(26);

    CASStyleProperty *property;
    CASStyleNode *node;

    node = styles[0];
    expect(node.styleSelector.stringValue).to.equal(@"UIButton");
    expect(node.styleProperties).to.haveCountOf(1);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"backgroundColor1");
    expect(property.values).to.equal(@[[UIColor cas_colorWithHex:@"#fff"]]);
    expect(node.deviceSelector.stringValue).to.beNil();

    node = styles[1];
    expect(node.styleSelector.stringValue).to.equal(@"UIButton");
    expect(node.styleProperties).to.haveCountOf(2);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"backgroundColor2");
    expect(property.values).to.equal(@[@"black"]);
    property = node.styleProperties[1];
    expect(property.name).to.equal(@"textColor");
    expect(property.values).to.equal(@[@"orange"]);
    expect(node.deviceSelector.stringValue).to.equal(@"pad");
    [given([mockDevice userInterfaceIdiom]) willReturnInteger:UIUserInterfaceIdiomPad];
    expect(node.deviceSelector.isValid).to.beTruthy();
    [given([mockDevice userInterfaceIdiom]) willReturnInteger:UIUserInterfaceIdiomPhone];
    expect(node.deviceSelector.isValid).to.beFalsy();

    node = styles[2];
    expect(node.styleSelector.stringValue).to.equal(@"UIButton");
    expect(node.styleProperties).to.haveCountOf(2);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"backgroundColor2");
    expect(property.values).to.equal(@[@"black"]);
    property = node.styleProperties[1];
    expect(property.name).to.equal(@"textColor");
    expect(property.values).to.equal(@[@"orange"]);
    expect(node.deviceSelector.stringValue).to.equal(@"(version:>=6)");

    [given([mockDevice systemVersion]) willReturn:@"6.1"];
    expect(node.deviceSelector.isValid).to.beTruthy();
    [given([mockDevice systemVersion]) willReturn:@"6.0.0"];
    expect(node.deviceSelector.isValid).to.beTruthy();
    [given([mockDevice systemVersion]) willReturn:@"7.0.4"];
    expect(node.deviceSelector.isValid).to.beTruthy();
    [given([mockDevice systemVersion]) willReturn:@"4.0.0"];
    expect(node.deviceSelector.isValid).to.beFalsy();

    node = styles[3];
    expect(node.styleSelector.stringValue).to.equal(@"UIButton");
    expect(node.styleProperties).to.haveCountOf(1);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"backgroundColor3");
    expect(property.values).to.equal(@[@"blue"]);
    expect(node.deviceSelector.stringValue).to.equal(@"(version:>=7.0.1)");

    node = styles[4];
    expect(node.styleSelector.stringValue).to.equal(@"UIButton");
    expect(node.styleProperties).to.haveCountOf(0);
    expect(node.deviceSelector.stringValue).to.equal(@"phone");

    [given([mockDevice userInterfaceIdiom]) willReturnInteger:UIUserInterfaceIdiomPad];
    expect(node.deviceSelector.isValid).to.beFalsy();
    [given([mockDevice userInterfaceIdiom]) willReturnInteger:UIUserInterfaceIdiomPhone];
    expect(node.deviceSelector.isValid).to.beTruthy();

    node = styles[5];
    expect(node.styleSelector.stringValue).to.equal(@"UIButton > UIControl");
    expect(node.styleProperties).to.haveCountOf(1);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"amazing");
    expect(property.values).to.equal(@[@23]);
    expect(node.deviceSelector.stringValue).to.equal(@"phone");

    node = styles[6];
    expect(node.styleSelector.stringValue).to.equal(@"UIButton UISlider");
    expect(node.styleProperties).to.haveCountOf(1);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"hello");
    expect(property.values).to.equal(@[@61]);
    expect(node.deviceSelector.stringValue).to.beNil();

    node = styles[7];
    expect(node.styleSelector.stringValue).to.equal(@"UIButton UISlider");
    expect(node.styleProperties).to.haveCountOf(0);
    expect(node.deviceSelector.stringValue).to.equal(@"phone");

    node = styles[8];
    expect(node.styleSelector.stringValue).to.equal(@"UIButton UISlider");
    expect(node.styleProperties).to.haveCountOf(1);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"textColor");
    expect(property.values).to.equal(@[@"brown"]);
    expect(node.deviceSelector.stringValue).to.equal(@"(version:<=6.1) and phone");

    [given([mockDevice systemVersion]) willReturn:@"5.2"];
    [given([mockDevice userInterfaceIdiom]) willReturnInteger:UIUserInterfaceIdiomPhone];
    expect(node.deviceSelector.isValid).to.beTruthy();

    [given([mockDevice userInterfaceIdiom]) willReturnInteger:UIUserInterfaceIdiomPad];
    expect(node.deviceSelector.isValid).to.beFalsy();

    node = styles[9];
    expect(node.styleSelector.stringValue).to.equal(@"UIView");
    expect(node.styleProperties).to.haveCountOf(0);
    expect(node.deviceSelector.stringValue).to.beNil();

    node = styles[10];
    expect(node.styleSelector.stringValue).to.equal(@"UIView");
    expect(node.styleProperties).to.haveCountOf(1);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"borderColor");
    expect(property.values).to.equal(@[[UIColor cas_colorWithHex:@"#ddd"]]);
    expect(node.deviceSelector.stringValue).to.equal(@"pad");

    node = styles[11];
    expect(node.styleSelector.stringValue).to.equal(@"UIView UINavigationBar");
    expect(node.styleProperties).to.haveCountOf(0);
    expect(node.deviceSelector.stringValue).to.equal(@"pad");

    node = styles[12];
    expect(node.styleSelector.stringValue).to.equal(@"UIView UINavigationBar > UIView");
    expect(node.styleProperties).to.haveCountOf(0);
    expect(node.deviceSelector.stringValue).to.equal(@"pad");

    node = styles[13];
    expect(node.styleSelector.stringValue).to.equal(@"UIView UINavigationBar > UIView");
    expect(node.styleProperties).to.haveCountOf(1);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"backgroundColor");
    expect(property.values).to.equal(@[[UIColor cas_colorWithHex:@"#eee"]]);
    expect(node.deviceSelector.stringValue).to.equal(@"(version:5.0.1) and pad");

    node = styles[14];
    expect(node.styleSelector.stringValue).to.equal(@"UITabBar.nice");
    expect(node.styleProperties).to.haveCountOf(0);
    expect(node.deviceSelector.stringValue).to.beNil();

    node = styles[15];
    expect(node.styleSelector.stringValue).to.equal(@"UISegmentedControl.nice");
    expect(node.styleProperties).to.haveCountOf(0);
    expect(node.deviceSelector.stringValue).to.beNil();

    node = styles[16];
    expect(node.styleSelector.stringValue).to.equal(@"UITabBar.nice UITextField");
    expect(node.styleProperties).to.haveCountOf(1);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"borderWidth");
    expect(property.values).to.equal(@[@2]);
    expect(node.deviceSelector.stringValue).to.beNil();

    node = styles[17];
    expect(node.styleSelector.stringValue).to.equal(@"UISegmentedControl.nice UITextField");
    expect(node.styleProperties).to.haveCountOf(1);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"borderWidth");
    expect(property.values).to.equal(@[@2]);
    expect(node.deviceSelector.stringValue).to.beNil();

    node = styles[18];
    expect(node.styleSelector.stringValue).to.equal(@"UITabBar.nice UITextField");
    expect(node.styleProperties).to.haveCountOf(0);
    expect(node.deviceSelector.stringValue).to.equal(@"(version:>5)");

    node = styles[19];
    expect(node.styleSelector.stringValue).to.equal(@"UISegmentedControl.nice UITextField");
    expect(node.styleProperties).to.haveCountOf(0);
    expect(node.deviceSelector.stringValue).to.equal(@"(version:>5)");

    node = styles[20];
    expect(node.styleSelector.stringValue).to.equal(@"UITabBar.nice UITextField.nicer");
    expect(node.styleProperties).to.haveCountOf(1);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"borderWidth");
    expect(property.values).to.equal(@[@3]);
    expect(node.deviceSelector.stringValue).to.equal(@"(version:>5)");

    node = styles[21];
    expect(node.styleSelector.stringValue).to.equal(@"UISegmentedControl.nice UITextField.nicer");
    expect(node.styleProperties).to.haveCountOf(1);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"borderWidth");
    expect(property.values).to.equal(@[@3]);
    expect(node.deviceSelector.stringValue).to.equal(@"(version:>5)");

    node = styles[22];
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"always");
    expect(property.values).to.equal(@[@1]);

    node = styles[23];
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"heighty");
    expect(property.values).to.equal(@[@2]);
    expect(node.deviceSelector.stringValue).to.equal(@"(screen-height:>200)");

    node = styles[24];
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"combinedtrue");
    expect(property.values).to.equal(@[@3]);
    [given([mockDevice systemVersion]) willReturn:@"7.0"];
    expect(node.deviceSelector.stringValue).to.equal(@"(screen-width:>100) and (version:>=6.0)");
    expect(node.deviceSelector.isValid).to.beTruthy();

    node = styles[25];
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"combinedfalse");
    expect(property.values).to.equal(@[@4]);
    [given([mockDevice systemVersion]) willReturn:@"6.0"];
    expect(node.deviceSelector.stringValue).to.equal(@"(version:<6.0) and (screen-width:>100)");
    expect(node.deviceSelector.isValid).to.beFalsy();
}

- (void)testVariablesBasic {
    NSError *error = nil;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Variables-Basic.cas" ofType:nil];
    NSArray *styles = [CASParser parserFromFilePath:filePath variables:nil error:&error].styleNodes;
    expect(error).to.beNil();

    expect(styles).to.haveCountOf(3);

    CASStyleProperty *property;
    CASStyleNode *node;

    node = styles[0];
    expect(node.styleSelector.stringValue).to.equal(@"UIView");
    expect(node.styleProperties).to.haveCountOf(1);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"layer");

    property = property.childStyleProperties[0];
    expect(property.name).to.equal(@"borderWidth");
    expect(property.values).to.equal(@[@2]);
    expect(node.deviceSelector.stringValue).to.beNil();

    property = node.styleProperties[0];
    property = property.childStyleProperties[1];
    expect(property.name).to.equal(@"shadowRadius");
    expect(property.values).to.equal(@[@2000]);
    expect(node.deviceSelector.stringValue).to.beNil();

    node = styles[1];
    expect(node.styleSelector.stringValue).to.equal(@"UITextField.one");
    expect(node.styleProperties).to.haveCountOf(2);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"font");
    expect(property.values).to.equal((@[@"Avenir-Heavy", @12]));
    expect(node.deviceSelector.stringValue).to.beNil();

    property = node.styleProperties[1];
    expect(property.name).to.equal(@"textInsets");
    expect(property.values).to.equal((@[@"(", @4, @3, @2, @1, @")"]));
    expect(node.deviceSelector.stringValue).to.beNil();

    node = styles[2];
    expect(node.styleSelector.stringValue).to.equal(@"UITextField.two");
    expect(node.styleProperties).to.haveCountOf(1);
    property = node.styleProperties[0];
    expect(property.name).to.equal(@"textInsets");
    expect(property.values).to.equal((@[@10, @2000, @20, @30]));
    expect(node.deviceSelector.stringValue).to.beNil();
}

- (void)testNSCoding {
    NSError *error = nil;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Nested.cas" ofType:nil];
    NSArray *styles = [CASParser parserFromFilePath:filePath variables:nil error:&error].styleNodes;
    expect(error).to.beNil();
    
    expect(styles).to.haveCountOf(3);

    NSData *serializedStyles = [NSKeyedArchiver archivedDataWithRootObject:styles];
    expect(serializedStyles).notTo.beNil();
    
    NSArray *deserializedStyles = [NSKeyedUnarchiver unarchiveObjectWithData:serializedStyles];
    expect(deserializedStyles).notTo.beNil();
    
    expect(styles.count).to.equal(deserializedStyles.count);
}

SpecEnd
