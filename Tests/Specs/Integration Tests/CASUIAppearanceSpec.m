//
//  CASUIAppearanceSpec.m
//  ClassyTests
//
//  Created by Jonas Budelmann on 25/10/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "Classy.h"
#import "XCTest+Spec.h"
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

    UIImage *highlightedImage = [[UIImage imageNamed:@"test_image_2"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 14, 13, 12)];
    expect([button backgroundImageForState:UIControlStateHighlighted].CGImage).to.equal(highlightedImage.CGImage);
    expect([button backgroundImageForState:UIControlStateHighlighted].capInsets).to.equal(highlightedImage.capInsets);
    expect([button backgroundImageForState:UIControlStateDisabled]).to.equal([UIImage imageNamed:@"test_image_3"]);
    expect([button backgroundImageForState:UIControlStateSelected]).to.equal([UIImage imageNamed:@"test_image_4"]);
}

- (void)testUIBarItemAppearance {
    UITabBarItem *view = UITabBarItem.new;
    [CASStyler.defaultStyler styleItem:view];

    NSDictionary *titleTextAttributes = [view titleTextAttributesForState:UIControlStateHighlighted];
    expect(titleTextAttributes[NSFontAttributeName]).to.equal([UIFont fontWithName:@"HelveticaNeue" size:21]);
    expect(titleTextAttributes[NSForegroundColorAttributeName]).to.equal([UIColor magentaColor]);
    expect(titleTextAttributes[NSBackgroundColorAttributeName]).to.equal([UIColor redColor]);
    expect(titleTextAttributes[NSLigatureAttributeName]).to.equal(@6);
    expect(titleTextAttributes[NSKernAttributeName]).to.equal(@0.6);
    expect(titleTextAttributes[NSStrikethroughStyleAttributeName]).to.equal(@(NSUnderlineStyleSingle));
    expect(titleTextAttributes[NSUnderlineStyleAttributeName]).to.equal(@(NSUnderlineStyleDouble));
    expect(titleTextAttributes[NSStrokeColorAttributeName]).to.equal([UIColor blueColor]);

    NSParagraphStyle *paragraphStyle = titleTextAttributes[NSParagraphStyleAttributeName];
    expect(paragraphStyle.lineSpacing).to.equal(20);
    expect(paragraphStyle.paragraphSpacing).to.equal(15);
    expect(paragraphStyle.alignment).to.equal(NSTextAlignmentCenter);
    expect(paragraphStyle.lineBreakMode).to.equal(NSLineBreakByTruncatingTail);

    NSShadow *shadow = titleTextAttributes[NSShadowAttributeName];
    expect(shadow.shadowOffset).to.equal(UIOffsetMake(1, 2));
    expect(shadow.shadowBlurRadius).to.equal(10);
    expect(shadow.shadowColor).to.equal([UIColor purpleColor]);
}

- (void)testUIBarButtonItemAppearance {
    UIBarButtonItem *view = UIBarButtonItem.new;
    [CASStyler.defaultStyler styleItem:view];

    expect([view backgroundImageForState:UIControlStateNormal barMetrics:UIBarMetricsDefault]).to.equal([UIImage imageNamed:@"test_image_1"]);
    expect([view backgroundImageForState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault]).to.equal([UIImage imageNamed:@"test_image_2"]);
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

- (void)testUIPageControlAppearance {
    UIPageControl *view = UIPageControl.new;
    [CASStyler.defaultStyler styleItem:view];

    expect([view pageIndicatorTintColor]).to.equal([UIColor purpleColor]);
    expect([view currentPageIndicatorTintColor]).to.equal([UIColor redColor]);
}

- (void)testUIProgressViewAppearance {
    UIProgressView *view = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [CASStyler.defaultStyler styleItem:view];

    expect([view progressImage]).to.equal([UIImage imageNamed:@"test_image_1"]);
    expect([view trackImage]).to.equal([UIImage imageNamed:@"test_image_2"]);

    //view cannot have both progressImage and progressTint. so we need to test seperately
    view.cas_styleClass = @"tinted";
    [CASStyler.defaultStyler styleItem:view];
    expect([view progressTintColor]).to.equal([UIColor darkGrayColor]);
    expect([view trackTintColor]).to.equal([UIColor lightGrayColor]);
}

- (void)testUISearchBarAppearance {
    UISearchBar *view = UISearchBar.new;
    [CASStyler.defaultStyler styleItem:view];

    expect([view barTintColor]).to.equal([UIColor brownColor]);
    expect([view backgroundImage].CGImage).to.equal([UIImage imageNamed:@"test_image_2"].CGImage);
    expect([view scopeBarBackgroundImage]).to.equal([UIImage imageNamed:@"test_image_3"]);
    expect([view searchFieldBackgroundPositionAdjustment]).to.equal(UIOffsetMake(20, 30));
    expect([view searchTextPositionAdjustment]).to.equal(UIOffsetMake(3, 4));

    expect([view scopeBarButtonBackgroundImageForState:UIControlStateSelected]).to.equal([UIImage imageNamed:@"test_image_1"]);
    expect([view scopeBarButtonDividerImageForLeftSegmentState:UIControlStateDisabled rightSegmentState:UIControlStateSelected]).to.equal([UIImage imageNamed:@"test_image_5"]);
    expect([view scopeBarButtonDividerImageForLeftSegmentState:UIControlStateHighlighted rightSegmentState:UIControlStateSelected]).to.beNil();

    expect([view positionAdjustmentForSearchBarIcon:UISearchBarIconClear]).to.equal(UIOffsetMake(5, 6));
    expect([view imageForSearchBarIcon:UISearchBarIconBookmark state:UIControlStateSelected]).to.equal([UIImage imageNamed:@"test_image_2"]);
}

- (void)testUISegmentedControlAppearance {
    UISegmentedControl *view = UISegmentedControl.new;
    [CASStyler.defaultStyler styleItem:view];

    expect([view backgroundImageForState:UIControlStateDisabled barMetrics:UIBarMetricsLandscapePhone]).to.equal([UIImage imageNamed:@"test_image_1"]);
    expect([view dividerImageForLeftSegmentState:UIControlStateDisabled rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault]).to.equal([UIImage imageNamed:@"test_image_5"]);
    expect([view contentPositionAdjustmentForSegmentType:UISegmentedControlSegmentLeft barMetrics:UIBarMetricsLandscapePhone]).to.equal(UIOffsetMake(1, 6));
}

- (void)testUISliderAppearance {
    UISlider *view = UISlider.new;
    [CASStyler.defaultStyler styleItem:view];

    expect([view minimumTrackImageForState:UIControlStateNormal]).to.equal([UIImage imageNamed:@"test_image_1"]);
    expect([view minimumTrackImageForState:UIControlStateHighlighted]).to.equal([UIImage imageNamed:@"test_image_2"]);
    expect([view maximumTrackImageForState:UIControlStateNormal]).to.equal([UIImage imageNamed:@"test_image_1"]);
    expect([view maximumTrackImageForState:UIControlStateHighlighted]).to.equal([UIImage imageNamed:@"test_image_2"]);
    expect([view thumbImageForState:UIControlStateNormal]).to.equal([UIImage imageNamed:@"test_image_1"]);
    expect([view thumbImageForState:UIControlStateHighlighted]).to.equal([UIImage imageNamed:@"test_image_2"]);

    // The slider cannot have both tint colors and custom images. So we need to test seperately
    view.cas_styleClass = @"tinted";
    [CASStyler.defaultStyler styleItem:view];
    
    expect([view minimumTrackTintColor]).to.equal([UIColor blackColor]);
    expect([view maximumTrackTintColor]).to.equal([UIColor purpleColor]);
    expect([view thumbTintColor]).to.equal([UIColor yellowColor]);
}

- (void)testUISteppterAppearance {
    UIStepper *view = UIStepper.new;
    [CASStyler.defaultStyler styleItem:view];

    //UISlider modifies this image. so cant verify
    //expect([view backgroundImageForState:UIControlStateHighlighted]).to.equal([UIImage imageNamed:@"test_image_1"]);
    expect([view dividerImageForLeftSegmentState:UIControlStateDisabled rightSegmentState:UIControlStateSelected]).to.equal([UIImage imageNamed:@"test_image_5"]);
    expect([view incrementImageForState:UIControlStateDisabled]).to.equal([UIImage imageNamed:@"test_image_2"]);
    expect([view decrementImageForState:UIControlStateDisabled]).to.equal([UIImage imageNamed:@"test_image_3"]);
}

- (void)testUISwitchAppearance {
    UISwitch *view = UISwitch.new;
    [CASStyler.defaultStyler styleItem:view];

    expect([view onImage]).to.equal([UIImage imageNamed:@"test_image_1"]);
    expect([view offImage]).to.equal([UIImage imageNamed:@"test_image_2"]);

    //view cannot have both progressImage and progressTint. so we need to test seperately
    view.cas_styleClass = @"tinted";
    [CASStyler.defaultStyler styleItem:view];
    expect([view onTintColor]).to.equal([UIColor cyanColor]);
    expect([view thumbTintColor]).to.equal([UIColor greenColor]);
}

- (void)testUITabBarAppearance {
    UITabBar *view = UITabBar.new;
    [CASStyler.defaultStyler styleItem:view];

    expect([view barTintColor]).to.equal([UIColor redColor]);
    expect([view backgroundImage].CGImage).to.equal([UIImage imageNamed:@"test_image_1"].CGImage);
    expect([view selectionIndicatorImage]).to.equal([UIImage imageNamed:@"test_image_2"]);
    expect([view shadowImage].CGImage).to.equal([UIImage imageNamed:@"test_image_3"].CGImage);
    expect([view itemPositioning]).to.equal(UITabBarItemPositioningCentered);
    expect(view.itemWidth).to.equal(10);
    expect(view.itemSpacing).to.equal(5);
    expect(view.barStyle).to.equal(UIBarStyleBlack);
}

- (void)testUITabBarItemAppearance {
    UITabBarItem *item = UITabBarItem.new;
    [CASStyler.defaultStyler styleItem:item];

    expect(item.titlePositionAdjustment).to.equal(UIOffsetMake(1, 2));
}

- (void)testUITableViewAppearance {
    UITableView *view = UITableView.new;
    [CASStyler.defaultStyler styleItem:view];

    expect(view.separatorInset).to.equal(UIEdgeInsetsMake(1, 2, 3, 4));
    expect(view.sectionIndexColor).to.equal([UIColor blueColor]);
    expect(view.sectionIndexBackgroundColor).to.equal([UIColor grayColor]);
    expect(view.sectionIndexTrackingBackgroundColor).to.equal([UIColor orangeColor]);
}

- (void)testUITableViewCellAppearance {
    UITableViewCell *view = UITableViewCell.new;
    
    // In iOS8, layoutMargins affects our separatorInset
    if ([view respondsToSelector:@selector(layoutMargins)]) {
        [view setValue:[NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero] forKey:@"layoutMargins"];
    }
    [CASStyler.defaultStyler styleItem:view];

    //top and bottom are ignored
    expect(view.separatorInset).to.equal(UIEdgeInsetsMake(0, 4, 0, 4));
}

- (void)testUIToolbarAppearance {
    UIToolbar *view = UIToolbar.new;
    [CASStyler.defaultStyler styleItem:view];

    expect(view.barTintColor).to.equal([UIColor magentaColor]);
    expect([view backgroundImageForToolbarPosition:UIBarPositionTop barMetrics:UIBarMetricsLandscapePhone].CGImage).to.equal([UIImage imageNamed:@"test_image_4"].CGImage);
    expect([view shadowImageForToolbarPosition:UIBarPositionBottom].CGImage).to.equal([UIImage imageNamed:@"test_image_3"].CGImage);
}

- (void)testUIViewAppearance {
    UIView *view = UIView.new;
    [CASStyler.defaultStyler styleItem:view];

    expect(view.backgroundColor).to.equal([UIColor cas_colorWithHex:@"#faf"]);
}

SpecEnd