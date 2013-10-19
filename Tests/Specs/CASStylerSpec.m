//
//  CASRendererSpec.m
//  Classy
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASStyler.h"
#import "UIColor+CASAdditions.h"
#import "CASStyleSelector.h"
#import "UIView+CASAdditions.h"
#import <objc/runtime.h>
#import "CASExampleView.h"
#import "UITextField+CASAdditions.h"

@interface CASStyler ()
@property (nonatomic, strong) NSMutableArray *styles;
@end

SpecBegin(CASStyler)

- (void)testGetViewDescriptor {
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIView-Basic.cas" ofType:nil];
    CASStyler *styler = [[CASStyler alloc] initWithFilePath:filePath error:nil];

    CASViewClassDescriptor *descriptor = [styler viewClassDescriptorForClass:UISlider.class];
    expect(descriptor.viewClass).to.equal(UISlider.class);
    expect(descriptor.parent.viewClass).to.equal(UIControl.class);
    expect(descriptor.parent.parent.viewClass).to.equal(UIView.class);
    expect(descriptor.parent.parent.parent).to.beNil();

    descriptor = [styler viewClassDescriptorForClass:UIView.class];
    expect(descriptor.viewClass).to.equal(UIView.class);
    expect(descriptor.parent).to.beNil();
}

- (void)testSortSelectorsByPrecedence {
    NSError *error = nil;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.cas" ofType:nil];
    CASStyler *styler = [[CASStyler alloc] initWithFilePath:filePath error:&error];
    expect(error).to.beNil();

    expect([styler.styles[0] stringValue]).to.equal(@"UIView.bordered");
    expect([styler.styles[1] stringValue]).to.equal(@"UIControl.border");
    expect([styler.styles[2] stringValue]).to.equal(@"UIButton[state:selected] UIControl");
    expect([styler.styles[3] stringValue]).to.equal(@"UINavigationBar UIButton");
    expect([styler.styles[4] stringValue]).to.equal(@"UISlider");
}

- (void)testSelectViewWithStyleClass {
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.cas" ofType:nil];
    CASStyler *styler = [[CASStyler alloc] initWithFilePath:filePath error:nil];

    CASStyleSelector *selector = styler.styles[0];
    expect([selector stringValue]).to.equal(@"UIView.bordered");
    expect([selector shouldSelectView:UIView.new]).to.beFalsy();

    UIView *view = UIView.new;
    view.cas_styleClass = @"bordered";
    expect([selector shouldSelectView:view]).to.beTruthy();
}

- (void)testSelectIndirectSuperview {
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.cas" ofType:nil];
    CASStyler *styler = [[CASStyler alloc] initWithFilePath:filePath error:nil];

    CASStyleSelector *selector = styler.styles[3];
    expect([selector stringValue]).to.equal(@"UINavigationBar UIButton");
    expect([selector shouldSelectView:UIButton.new]).to.beFalsy();

    //direct superview
    UIButton *button = UIButton.new;
    button.cas_styleClass = @"large";
    UINavigationBar *navigationBar = UINavigationBar.new;
    [navigationBar addSubview:button];
    expect([selector shouldSelectView:button]).to.beTruthy();

    //indirect superview
    [button removeFromSuperview];
    UIImageView *imageView = UIImageView.new;
    [imageView addSubview:button];
    [navigationBar addSubview:imageView];
    expect([selector shouldSelectView:button]).to.beTruthy();
}

- (void)testSelectSubclasses {
    CASStyleSelector *selector = CASStyleSelector.new;
    selector.viewClass = UIControl.class;
    selector.shouldSelectSubclasses = YES;
    expect([selector shouldSelectView:UIControl.new]).to.equal(YES);
    expect([selector shouldSelectView:UIView.new]).to.equal(NO);
    expect([selector shouldSelectView:UIButton.new]).to.equal(YES);
}

- (void)testSetBasicProperties {
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIView-Basic.cas" ofType:nil];
    CASStyler *styler = [[CASStyler alloc] initWithFilePath:filePath error:nil];
    UISlider *view = UISlider.new;
    [styler styleView:view];

    expect(view.cas_borderColor.cas_hexValue).to.equal(@"a1a1a1");
    expect(view.backgroundColor.cas_hexValue).to.equal(@"a2a2a2");
    expect(view.cas_borderWidth).to.equal(2);
    expect(view.cas_cornerRadius).to.equal(7);

    expect(view.cas_shadowColor.cas_hexValue).to.equal(@"a3a3a3");
    expect(view.cas_shadowOffset).to.equal(CGSizeMake(1, 3));
    expect(view.cas_shadowOpacity).to.equal(0.5);
    expect(view.cas_shadowRadius).to.equal(4);

    expect(view.contentMode).to.equal(UIViewContentModeScaleAspectFill);
}

- (void)testSetUITextFieldProperties {
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIView-Basic.cas" ofType:nil];
    CASStyler *styler = [[CASStyler alloc] initWithFilePath:filePath error:nil];
    UITextField *view = UITextField.new;

    expect(view.cas_textEdgeInsets).to.equal(UIEdgeInsetsZero);

    [styler styleView:view];

    CGRect bounds = CGRectMake(0, 0, 10, 10);
    expect(view.cas_textEdgeInsets).to.equal(UIEdgeInsetsMake(4, 3, 2, 1));
    expect([view textRectForBounds:bounds]).to.equal(UIEdgeInsetsInsetRect(bounds, view.cas_textEdgeInsets));
    expect(view.cas_fontName).to.equal(@"Avenir-Heavy");
    expect(view.cas_fontSize).to.equal(12);
    expect(view.textColor.cas_hexValue).to.equal(@"a0a0a0");
    expect(view.textAlignment).to.equal(NSTextAlignmentRight);
    expect(view.contentVerticalAlignment).to.equal(UIControlContentVerticalAlignmentBottom);
    expect(view.borderStyle).to.equal(UITextBorderStyleLine);
    expect(view.background).notTo.beNil();
    expect(view.background.capInsets).to.equal(UIEdgeInsetsMake(1, 2, 3, 4));
}

- (void)testSetCustomProperties {
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIView-Basic.cas" ofType:nil];
    CASStyler *styler = [[CASStyler alloc] initWithFilePath:filePath error:nil];
    CASExampleView *exampleView = CASExampleView.new;
    [styler styleView:exampleView];

    expect(exampleView.testCGFloat).to.equal(4.5);
    expect(exampleView.testBOOL).to.equal(YES);
    expect(exampleView.testNSInteger).to.equal(-999);
    expect(exampleView.testNSUInteger).to.equal(1000);
    expect(exampleView.testInt).to.equal(345);
}

SpecEnd