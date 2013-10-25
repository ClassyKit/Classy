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
    CASStyler *styler = CASStyler.new;
    styler.filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIView-Basic.cas" ofType:nil];

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
    CASStyler *styler = CASStyler.new;
    [styler setFilePath:filePath error:&error];
    expect(error).to.beNil();

    expect([styler.styles[0] stringValue]).to.equal(@"UIView.bordered");
    expect([styler.styles[1] stringValue]).to.equal(@"UIControl.border");
    expect([styler.styles[2] stringValue]).to.equal(@"UIButton UIControl[state:selected]");
    expect([styler.styles[3] stringValue]).to.equal(@"UINavigationBar UIButton");
    expect([styler.styles[4] stringValue]).to.equal(@"UISlider");
}

- (void)testSelectViewWithStyleClass {
    CASStyler *styler = CASStyler.new;
    styler.filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.cas" ofType:nil];

    CASStyleSelector *selector = styler.styles[0];
    expect([selector stringValue]).to.equal(@"UIView.bordered");
    expect([selector shouldSelectView:UIView.new]).to.beFalsy();

    UIView *view = UIView.new;
    view.cas_styleClass = @"bordered";
    expect([selector shouldSelectView:view]).to.beTruthy();
}

- (void)testSelectIndirectSuperview {
    CASStyler *styler = CASStyler.new;
    styler.filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.cas" ofType:nil];

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

SpecEnd