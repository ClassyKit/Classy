//
//  CASUIAppearanceSpec.m
//  ClassyTests
//
//  Created by Jonas Budelmann on 25/10/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "Classy.h"
#import "UIColor+CASAdditions.h"

SpecBegin(CASUIAppearance)

- (void)setUp {
    NSError *error = nil;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIAppearance-Basic.cas" ofType:nil];
    [CASStyler.defaultStyler setFilePath:filePath error:&error];
    expect(error).to.beNil();
}

- (void)testUIActivityIndicatorViewAppearance {
    UIActivityIndicatorView *view = UIActivityIndicatorView.new;
    [CASStyler.defaultStyler styleItem:view];

    expect(view.color).to.equal([UIColor redColor]);
}

- (void)testUIButtonAppearance {
    UIButton *button = UIButton.new;
    [CASStyler.defaultStyler styleItem:button];

    expect(button.contentEdgeInsets).to.equal(UIEdgeInsetsMake(1, 2, 3, 4));

    // titleColor
    expect([button titleColorForState:UIControlStateNormal]).to.equal([UIColor yellowColor]);
    expect([button titleColorForState:UIControlStateHighlighted]).to.equal([UIColor cas_colorWithHex:@"#e3e3e3"]);
    expect([button titleColorForState:UIControlStateDisabled]).to.equal([UIColor cas_colorWithHex:@"#e4e4e4"]);
    expect([button titleColorForState:UIControlStateSelected]).to.equal([UIColor cas_colorWithHex:@"#e5e5e5"]);

    // titleShadow
    expect([button titleShadowColorForState:UIControlStateNormal]).to.equal([UIColor cas_colorWithHex:@"#e6e6e6"]);
    expect([button titleShadowColorForState:UIControlStateHighlighted]).to.equal([UIColor cas_colorWithHex:@"#e7e7e7"]);
    expect([button titleShadowColorForState:UIControlStateDisabled]).to.equal([UIColor cas_colorWithHex:@"#f4f4f4"]);
    expect([button titleShadowColorForState:UIControlStateSelected]).to.equal([UIColor cas_colorWithHex:@"#f5f5f5"]);

    // backgroundImage
    expect([button backgroundImageForState:UIControlStateNormal]).to.equal([UIImage imageNamed:@"test_image_1"]);

    UIImage *highlightedImage = [[UIImage imageNamed:@"bg_button_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 14, 13, 12)];
    expect([button backgroundImageForState:UIControlStateHighlighted].CGImage).to.equal(highlightedImage.CGImage);
    expect([button backgroundImageForState:UIControlStateHighlighted].capInsets).to.equal(highlightedImage.capInsets);
    expect([button backgroundImageForState:UIControlStateDisabled]).to.equal([UIImage imageNamed:@"test_image_3"]);
    expect([button backgroundImageForState:UIControlStateSelected]).to.equal([UIImage imageNamed:@"test_image_4"]);
}

- (void)testUIBarButtonItemAppearance {
    UIBarButtonItem *view = UIBarButtonItem.new;
    [CASStyler.defaultStyler styleItem:view];

    expect([view backgroundImageForState:UIControlStateNormal barMetrics:UIBarMetricsDefault]).to.equal([UIImage imageNamed:@"test_image_1"]);
    expect([view backgroundImageForState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault]).to.equal([UIImage imageNamed:@"bg_button_highlighted"]);
    expect([view backgroundImageForState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone]).to.equal([UIImage imageNamed:@"test_image_4"]);

    expect([view backgroundVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefaultPrompt]).to.equal(10);
    expect([view backgroundVerticalPositionAdjustmentForBarMetrics:UIBarMetricsLandscapePhone]).to.equal(20);

    expect([view titlePositionAdjustmentForBarMetrics:UIBarMetricsDefault]).to.equal(UIOffsetMake(11, 12));
    expect([view titlePositionAdjustmentForBarMetrics:UIBarMetricsLandscapePhone]).to.equal(UIOffsetMake(21, 22));


    //back
    expect([view backButtonBackgroundImageForState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault]).to.equal([UIImage imageNamed:@"test_image_3"]);
    expect([view backButtonBackgroundImageForState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone]).to.equal([UIImage imageNamed:@"test_image_1"]);


    expect([view backButtonBackgroundVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefaultPrompt]).to.equal(50);
    expect([view backButtonBackgroundVerticalPositionAdjustmentForBarMetrics:UIBarMetricsLandscapePhone]).to.equal(60);

    expect([view backButtonTitlePositionAdjustmentForBarMetrics:UIBarMetricsDefault]).to.equal(UIOffsetMake(51, 52));
    expect([view backButtonTitlePositionAdjustmentForBarMetrics:UIBarMetricsLandscapePhone]).to.equal(UIOffsetMake(61, 62));

}

- (void)testUINavigationBarAppearance {
    UINavigationBar *view = UINavigationBar.new;
    [CASStyler.defaultStyler styleItem:view];

    expect([view barTintColor]).to.equal([UIColor blueColor]);
    expect([view shadowImage].CGImage).to.equal([UIImage imageNamed:@"test_image_1"].CGImage);
    expect([view backIndicatorImage]).to.equal([UIImage imageNamed:@"test_image_4"]);
    expect([view backIndicatorTransitionMaskImage]).to.equal([UIImage imageNamed:@"test_image_3"]);

    expect([view backgroundImageForBarPosition:UIBarPositionTop barMetrics:UIBarMetricsLandscapePhone].CGImage).to.equal([UIImage imageNamed:@"test_image_4"].CGImage);
    expect([view titleVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefaultPrompt]);
}

SpecEnd