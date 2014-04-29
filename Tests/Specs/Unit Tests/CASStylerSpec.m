//
//  CASRendererSpec.m
//  Classy
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASStyler.h"
#import "XCTest+Spec.h"
#import "UIColor+CASAdditions.h"
#import "CASStyleSelector.h"
#import "UIView+CASAdditions.h"
#import <objc/runtime.h>
#import "CASExampleView.h"
#import "UITextField+CASAdditions.h"
#import "CASStyleNode.h"
#import "UIDevice+CASMockDevice.h"


@interface CASStyler ()
@property (nonatomic, strong) NSMutableArray *styleNodes;
@end

SpecBegin(CASStyler){
    UIDevice *mockDevice;
}

- (void)setUp {
    mockDevice = mock(UIDevice.class);
    [UIDevice setMockDevice:mockDevice];
}

- (void)tearDown {
    [UIDevice setMockDevice:nil];
}

- (void)testGetViewDescriptor {
    CASStyler *styler = CASStyler.new;
    styler.filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIView-Basic.cas" ofType:nil];

    CASObjectClassDescriptor *descriptor = [styler objectClassDescriptorForClass:UISlider.class];
    expect(descriptor.objectClass).to.equal(UISlider.class);
    expect(descriptor.parent.objectClass).to.equal(UIControl.class);
    expect(descriptor.parent.parent.objectClass).to.equal(UIView.class);
    expect(descriptor.parent.parent.parent).to.beNil();

    descriptor = [styler objectClassDescriptorForClass:UIView.class];
    expect(descriptor.objectClass).to.equal(UIView.class);
    expect(descriptor.parent).to.beNil();
}

- (void)testSortSelectorsByPrecedence {
    NSError *error = nil;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.cas" ofType:nil];
    CASStyler *styler = CASStyler.new;
    [styler setFilePath:filePath error:&error];
    expect(error).to.beNil();

    expect([[styler.styleNodes[0] styleSelector] stringValue]).to.equal(@"UISlider");
    expect([[styler.styleNodes[1] styleSelector] stringValue]).to.equal(@"UIButton UIControl[state:selected]");
    expect([[styler.styleNodes[2] styleSelector] stringValue]).to.equal(@"UINavigationBar UIButton");
    expect([[styler.styleNodes[3] styleSelector] stringValue]).to.equal(@"UIView.bordered");
    expect([[styler.styleNodes[4] styleSelector] stringValue]).to.equal(@"UIControl.border");
}

- (void)testSelectViewWithStyleClass {
    CASStyler *styler = CASStyler.new;
    styler.filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.cas" ofType:nil];

    CASStyleSelector *selector = [styler.styleNodes[3] styleSelector];
    expect([selector stringValue]).to.equal(@"UIView.bordered");
    expect([selector shouldSelectItem:UIView.new]).to.beFalsy();

    UIView *view = UIView.new;
    view.cas_styleClass = @"bordered";
    expect([selector shouldSelectItem:view]).to.beTruthy();
}

- (void)testSelectIndirectSuperview {
    CASStyler *styler = CASStyler.new;
    styler.filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.cas" ofType:nil];

    CASStyleSelector *selector = [styler.styleNodes[2] styleSelector];
    expect([selector stringValue]).to.equal(@"UINavigationBar UIButton");
    expect([selector shouldSelectItem:UIButton.new]).to.beFalsy();

    //direct superview
    UIButton *button = UIButton.new;
    button.cas_styleClass = @"large";
    UINavigationBar *navigationBar = UINavigationBar.new;
    [navigationBar addSubview:button];
    expect([selector shouldSelectItem:button]).to.beTruthy();

    //indirect superview
    [button removeFromSuperview];
    UIImageView *imageView = UIImageView.new;
    [imageView addSubview:button];
    [navigationBar addSubview:imageView];
    expect([selector shouldSelectItem:button]).to.beTruthy();
}

- (void)testSelectSubclasses {
    CASStyleSelector *selector = CASStyleSelector.new;
    selector.objectClass = UIControl.class;
    selector.shouldSelectSubclasses = YES;
    expect([selector shouldSelectItem:UIControl.new]).to.equal(YES);
    expect([selector shouldSelectItem:UIView.new]).to.equal(NO);
    expect([selector shouldSelectItem:UIButton.new]).to.equal(YES);
}

- (void)testImport {
    CASStyler *styler = CASStyler.new;
    styler.filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Import-Base.cas" ofType:nil];

    UIView *view = UIView.new;
    CASStyleNode *node = styler.styleNodes[0];
    expect(node.styleSelector.stringValue).to.equal(@"UIView.two");
    view.cas_styleClass = @"two";
    [styler styleItem:view];
    expect(view.backgroundColor).to.equal([UIColor purpleColor]);
    expect(view.layer.cornerRadius).to.equal(6);
    expect(view.layer.shadowOffset).to.equal(UIOffsetMake(5, 5));

    node = styler.styleNodes[1];
    expect(node.styleSelector.stringValue).to.equal(@"UIView.one");
    view.cas_styleClass = @"one";
    [styler styleItem:view];
    expect(view.backgroundColor).to.equal([UIColor blueColor]);
    expect(view.layer.cornerRadius).to.equal(5);
    expect(view.layer.shadowOffset).to.equal(UIOffsetMake(6, 6));
    expect(view.layer.shadowOpacity).to.equal(3);
    expect(view.layer.shadowRadius).to.equal(4);

    node = styler.styleNodes[2];
    expect(node.styleSelector.stringValue).to.equal(@"UIView.base");

    view.cas_styleClass = @"base";
    [styler styleItem:view];
    expect(view.backgroundColor).to.equal([UIColor redColor]);
    expect(view.layer.cornerRadius).to.equal(3);
    expect(view.layer.shadowOffset).to.equal(UIOffsetMake(4, 4));
    expect(view.layer.shadowOpacity).to.equal(5);
    expect(view.layer.shadowRadius).to.equal(6);
}

- (void)testMediaQueriesOnPad {
    [given([mockDevice userInterfaceIdiom]) willReturnInteger:UIUserInterfaceIdiomPad];
    [given([mockDevice systemVersion]) willReturn:@"7.0.1"];
    
    CASStyler *styler = CASStyler.new;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Media-Queries-styler.cas" ofType:nil];
    
    NSError *error = nil;
    [styler setFilePath:filePath error:&error];
    expect(error).to.beNil();
    
    expect(styler.styleNodes).to.haveCountOf(0);
}

- (void)testMediaQueriesOnPhone {
    [given([mockDevice userInterfaceIdiom]) willReturnInteger:UIUserInterfaceIdiomPhone];
    [given([mockDevice systemVersion]) willReturn:@"7.0.1"];
    
    CASStyler *styler = CASStyler.new;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Media-Queries-styler.cas" ofType:nil];
    
    NSError *error = nil;
    [styler setFilePath:filePath error:&error];
    expect(error).to.beNil();
    
    expect(styler.styleNodes).to.haveCountOf(2);
    
    UILabel *view = UILabel.new;
    CASStyleNode *node = styler.styleNodes[0];
    expect(node.styleSelector.stringValue).to.equal(@"UILabel.label2");
    view.cas_styleClass = @"label2";
    [styler styleItem:view];
    expect(view.textColor).to.equal([UIColor cas_colorWithHex:@"#00f"]);
    expect(view.font).to.equal([UIFont fontWithName:@"HelveticaNeue" size:120]);
}

- (void)testMediaQueriesOnPhoneLessThan7 {
    [given([mockDevice userInterfaceIdiom]) willReturnInteger:UIUserInterfaceIdiomPhone];
    [given([mockDevice systemVersion]) willReturn:@"6.1"];
    
    CASStyler *styler = CASStyler.new;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Selectors-Media-Queries-styler.cas" ofType:nil];
    
    NSError *error = nil;
    [styler setFilePath:filePath error:&error];
    expect(error).to.beNil();
    
    expect(styler.styleNodes).to.haveCountOf(2);
    
    UILabel *view = UILabel.new;
    CASStyleNode *node = styler.styleNodes[0];
    expect(node.styleSelector.stringValue).to.equal(@"UILabel.label2");
    view.cas_styleClass = @"label2";
    [styler styleItem:view];
    expect(view.textColor).to.equal([UIColor cas_colorWithHex:@"#0f0"]);
    expect(view.font).to.equal([UIFont fontWithName:@"HelveticaNeue" size:120]);
}

- (void)testPrecedence1 {
    CASStyler *styler = CASStyler.new;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Precedence-1.cas" ofType:nil];

    NSError *error = nil;
    [styler setFilePath:filePath error:&error];
    expect(error).to.beNil();

    expect(styler.styleNodes).to.haveCountOf(5);

    UITextField *view = UITextField.new;
    [styler styleItem:view];
    expect(view.cas_textEdgeInsets).to.equal(UIEdgeInsetsMake(10, 10, 10, 10));

    UIView *superview = UIView.new;
    [superview addSubview:view];
    [styler styleItem:view];
    expect(view.cas_textEdgeInsets).to.equal(UIEdgeInsetsMake(5, 5, 5, 5));

    view.cas_styleClass = @"twenty";
    [styler styleItem:view];
    expect(view.cas_textEdgeInsets).to.equal(UIEdgeInsetsMake(20, 20, 20, 20));
    
    UILabel *label = UILabel.new;
    [styler styleItem:label];
    expect(label.textColor).to.equal([UIColor cas_colorWithHex:@"#f00"]);
}

- (void)testPrecedence2 {
    CASStyler *styler = CASStyler.new;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Precedence-2.cas" ofType:nil];

    NSError *error = nil;
    [styler setFilePath:filePath error:&error];
    expect(error).to.beNil();

    expect(styler.styleNodes).to.haveCountOf(3);

    UITextField *view = UITextField.new;
    [styler styleItem:view];
    expect(view.cas_textEdgeInsets).to.equal(UIEdgeInsetsMake(10, 10, 10, 10));

    UIView *superview = UIView.new;
    [superview addSubview:view];
    [styler styleItem:view];
    expect(view.cas_textEdgeInsets).to.equal(UIEdgeInsetsMake(5, 5, 5, 5));

    view.cas_styleClass = @"twenty";
    [styler styleItem:view];
    expect(view.cas_textEdgeInsets).to.equal(UIEdgeInsetsMake(20, 20, 20, 20));
}

- (void)testVariablesInjection {
    CASStyler *styler = CASStyler.new;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Variables-Injection.cas" ofType:nil];

    NSError *error = nil;
    styler.variables = @{
        @"$filename" : @"'Injected-File.cas'",
        @"$namedColor" : @"purple",
        @"$hexColor" : @"#333",
        @"$bool" : @YES,
        @"$unit" : @200,
        @"$insets" : @"20, 15, 12, 10",
    };
    [styler setFilePath:filePath error:&error];
    expect(error).to.beNil();

    expect(styler.styleNodes).to.haveCountOf(2);

    CASStyleNode *node = styler.styleNodes[0];
    expect(node.styleSelector.stringValue).to.equal(@"UIView");
    UIView *view2 = UIView.new;
    [styler styleItem:view2];
    expect(view2.backgroundColor).to.equal([UIColor purpleColor]);

    node = styler.styleNodes[1];
    expect(node.styleSelector.stringValue).to.equal(@"UITextField");

    UITextField *view = UITextField.new;
    [styler styleItem:view];
    expect(view.textColor).to.equal([UIColor cas_colorWithHex:@"#333"]);
    expect(view.cas_textEdgeInsets).to.equal(UIEdgeInsetsMake(20, 15, 12, 10));
    expect(view.clearsOnBeginEditing).to.equal(YES);
    expect(view.minimumFontSize).to.equal(200);
}

SpecEnd