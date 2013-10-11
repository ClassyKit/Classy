//
//  MODRendererSpec.m
//  Mod
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODStyler.h"
#import "UIColor+MODAdditions.h"
#import "MODStyleSelector.h"
#import "UIView+MODAdditions.h"

@interface MODStyler ()
@property (nonatomic, strong) NSMutableArray *styles;
@end

SpecBegin(MODStyler)

it(@"should sort selectors by precedence", ^{
    NSError *error = nil;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.mod" ofType:nil];
    MODStyler *styler = [[MODStyler alloc] initWithFilePath:filePath error:&error];
    expect(error).to.beNil();

    expect([styler.styles[0] stringValue]).to.equal(@"UIView.bordered");
    expect([styler.styles[1] stringValue]).to.equal(@"UIControl.border");
    expect([styler.styles[2] stringValue]).to.equal(@"UIButton[state:selected] UIControl");
    expect([styler.styles[3] stringValue]).to.equal(@"UINavigationBar UIButton");
    expect([styler.styles[4] stringValue]).to.equal(@"UISlider");
});

it(@"should select view with styleClass", ^{
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.mod" ofType:nil];
    MODStyler *styler = [[MODStyler alloc] initWithFilePath:filePath error:nil];

    MODStyleSelector *selector = styler.styles[0];
    expect([selector stringValue]).to.equal(@"UIView.bordered");
    expect([selector shouldSelectView:UIView.new]).to.beFalsy();

    UIView *view = UIView.new;
    view.mod_styleClass = @"bordered";
    expect([selector shouldSelectView:view]).to.beTruthy();
});

it(@"should select indirect superview", ^{
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.mod" ofType:nil];
    MODStyler *styler = [[MODStyler alloc] initWithFilePath:filePath error:nil];

    MODStyleSelector *selector = styler.styles[3];
    expect([selector stringValue]).to.equal(@"UINavigationBar UIButton");
    expect([selector shouldSelectView:UIButton.new]).to.beFalsy();

    //direct superview
    UIButton *button = UIButton.new;
    button.mod_styleClass = @"large";
    UINavigationBar *navigationBar = UINavigationBar.new;
    [navigationBar addSubview:button];
    expect([selector shouldSelectView:button]).to.beTruthy();

    //indirect superview
    [button removeFromSuperview];
    UIImageView *imageView = UIImageView.new;
    [imageView addSubview:button];
    [navigationBar addSubview:imageView];
    expect([selector shouldSelectView:button]).to.beTruthy();
});

it(@"should set basic properties", ^{
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIView-Basic.mod" ofType:nil];
    MODStyler *styler = [[MODStyler alloc] initWithFilePath:filePath error:nil];
    UIView *view = UIView.new;
    [styler styleView:view];

    expect(view.backgroundColor.mod_hexValue).to.equal(@"a2a2a2");
    expect([UIColor colorWithCGColor:view.layer.borderColor].mod_hexValue).to.equal(@"a1a1a1");
    expect(view.layer.borderWidth).to.equal(2);
    expect(view.layer.cornerRadius).to.equal(7);
});

SpecEnd