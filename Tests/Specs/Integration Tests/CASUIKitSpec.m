//
//  CASUIKitSpec.m
//  ClassyTests
//
//  Created by Jonas Budelmann on 25/10/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "Classy.h"

SpecBegin(CASUIKit)

- (void)testSetUIViewProperties {
    CASStyler *styler = CASStyler.new;
    styler.filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIKit-Basic.cas" ofType:nil];
    UIView *view = UIView.new;
    [styler styleItem:view];

    expect(view.cas_borderColor.cas_hexValue).to.equal(@"a1a1a1");
    expect(view.backgroundColor.cas_hexValue).to.equal(@"a2a2a2");
    expect(view.cas_borderWidth).to.equal(2);
    expect(view.cas_cornerRadius).to.equal(7);

    expect(view.cas_shadowColor).to.equal([UIColor redColor]);
    expect(view.cas_shadowOffset).to.equal(CGSizeMake(1, 3));
    expect(view.cas_shadowOpacity).to.equal(0.5);
    expect(view.cas_shadowRadius).to.equal(4);

    expect(view.contentMode).to.equal(UIViewContentModeScaleAspectFill);
}

- (void)testSetUITextFieldProperties {
    CASStyler *styler = CASStyler.new;
    styler.filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIKit-Basic.cas" ofType:nil];
    UITextField *view = UITextField.new;

    expect(view.cas_textEdgeInsets).to.equal(UIEdgeInsetsZero);

    [styler styleItem:view];

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

SpecEnd