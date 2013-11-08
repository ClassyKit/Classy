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
#import "CASStyleNode.h"

@interface CASStyler ()
@property (nonatomic, strong) NSMutableArray *styleNodes;
@end

SpecBegin(CASStyler)

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

    expect([[styler.styleNodes[0] styleSelector] stringValue]).to.equal(@"UIView.bordered");
    expect([[styler.styleNodes[1] styleSelector] stringValue]).to.equal(@"UIControl.border");
    expect([[styler.styleNodes[2] styleSelector] stringValue]).to.equal(@"UIButton UIControl[state:selected]");
    expect([[styler.styleNodes[3] styleSelector] stringValue]).to.equal(@"UINavigationBar UIButton");
    expect([[styler.styleNodes[4] styleSelector] stringValue]).to.equal(@"UISlider");
}

- (void)testSelectViewWithStyleClass {
    CASStyler *styler = CASStyler.new;
    styler.filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.cas" ofType:nil];

    CASStyleSelector *selector = [styler.styleNodes[0] styleSelector];
    expect([selector stringValue]).to.equal(@"UIView.bordered");
    expect([selector shouldSelectItem:UIView.new]).to.beFalsy();

    UIView *view = UIView.new;
    view.cas_styleClass = @"bordered";
    expect([selector shouldSelectItem:view]).to.beTruthy();
}

- (void)testSelectIndirectSuperview {
    CASStyler *styler = CASStyler.new;
    styler.filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.cas" ofType:nil];

    CASStyleSelector *selector = [styler.styleNodes[3] styleSelector];
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

SpecEnd