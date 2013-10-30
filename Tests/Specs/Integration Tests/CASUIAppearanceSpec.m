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
    [CASStyler.defaultStyler styleView:view];

    expect(view.color).to.equal([UIColor redColor]);
}

- (void)testUIButtonAppearance {
    UIButton *button = UIButton.new;
    [CASStyler.defaultStyler styleView:button];

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
    expect([button backgroundImageForState:UIControlStateNormal]).to.equal([UIImage imageNamed:@"bg_button_normal"]);

    UIImage *highlightedImage = [[UIImage imageNamed:@"bg_button_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 14, 13, 12)];
    expect([button backgroundImageForState:UIControlStateHighlighted].CGImage).to.equal(highlightedImage.CGImage);
    expect([button backgroundImageForState:UIControlStateHighlighted].capInsets).to.equal(highlightedImage.capInsets);
    expect([button backgroundImageForState:UIControlStateDisabled]).to.equal([UIImage imageNamed:@"bg_button_disabled"]);
    expect([button backgroundImageForState:UIControlStateSelected]).to.equal([UIImage imageNamed:@"bg_button_selected"]);
}


SpecEnd