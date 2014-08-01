//
//  CASUIKitSpec.m
//  ClassyTests
//
//  Created by Jonas Budelmann on 25/10/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "Classy.h"
#import "XCTest+Spec.h"

SpecBegin(CASUIKit)

- (void)testSetUIViewProperties {
    CASStyler *styler = CASStyler.new;
    styler.filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIKit-Basic.cas" ofType:nil];
    UIView *view = UIView.new;
    [styler styleItem:view];

    expect([UIColor colorWithCGColor:view.layer.borderColor].cas_hexValue).to.equal(@"a1a1a1");
    expect(view.backgroundColor.cas_hexValue).to.equal(@"a2a2a2");
    expect(view.layer.borderWidth).to.equal(2);
    expect(view.layer.cornerRadius).to.equal(7);

    expect([UIColor colorWithCGColor:view.layer.shadowColor]).to.equal([UIColor redColor]);
    expect(view.layer.shadowOffset).to.equal(CGSizeMake(1, 3));
    expect(view.layer.shadowOpacity).to.equal(0.5);
    expect(view.layer.shadowRadius).to.equal(4);

    expect(view.contentMode).to.equal(UIViewContentModeScaleAspectFill);
    expect(view.clipsToBounds).to.equal(YES);

    expect(view.tintColor).to.equal([UIColor blueColor]);
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
    expect(view.font).to.equal([UIFont fontWithName:@"Avenir-Heavy" size:12]);
    expect(view.textColor.cas_hexValue).to.equal(@"a0a0a0");
    expect(view.textAlignment).to.equal(NSTextAlignmentRight);
    expect(view.contentVerticalAlignment).to.equal(UIControlContentVerticalAlignmentBottom);
    expect(view.borderStyle).to.equal(UITextBorderStyleLine);
    expect(view.background).notTo.beNil();
    expect(view.background.capInsets).to.equal(UIEdgeInsetsMake(1, 2, 3, 4));
}

- (void)testMultipleStyleClasses {
    CASStyler *styler = CASStyler.new;
    styler.filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIKit-MultipleClasses.cas" ofType:nil];
    UIView *view = UIView.new;
    view.cas_styleClass = @"class1";
    [view cas_addStyleClass:@"class2"];
    [styler styleItem:view];
    expect(view.backgroundColor).to.equal([UIColor redColor]);
    expect(view.layer.cornerRadius).to.equal(2);
    [view cas_addStyleClass:@"class3"];
    [styler styleItem:view];
    expect(view.backgroundColor).to.equal([UIColor greenColor]);
}

SpecEnd