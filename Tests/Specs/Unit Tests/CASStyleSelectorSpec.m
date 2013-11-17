//
//  CASStyleSelectorSpec.m
//  ClassyTests
//
//  Created by Jonas Budelmann on 30/10/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "CASStyleSelector.h"
#import "UIView+CASAdditions.h"
#import "UIViewController+CASAdditions.h"
#import "CASExampleView.h"
#import "CASExampleViewController.h"

/**
 *  Test helper method for making sure we have created correct view hierarchy
 */
NSString * CASStringViewHierarchyFromView(UIView *view) {
    NSMutableString *viewHierarchy = NSMutableString.new;
	for (UIView *ancestor = view; ancestor != nil; ancestor = ancestor.superview) {
        if (ancestor.cas_styleClass.length) {
            [viewHierarchy insertString:[NSString stringWithFormat:@".%@", ancestor.cas_styleClass] atIndex:0];
        }
        [viewHierarchy insertString:[NSString stringWithFormat:@" > %@", NSStringFromClass(ancestor.class)] atIndex:0];
    }
    return [viewHierarchy stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" >"]];
}

SpecBegin(CASStyleSelector)

- (void)testSelectViewClass {
    CASStyleSelector *selector = CASStyleSelector.new;

    selector.objectClass = UIView.class;
    expect(selector.stringValue).to.equal(@"UIView");
    expect([selector shouldSelectItem:UIView.new]).to.beTruthy();
    expect([selector shouldSelectItem:UISlider.new]).to.beFalsy();

    selector.objectClass = UITabBar.class;
    expect(selector.stringValue).to.equal(@"UITabBar");
    expect([selector shouldSelectItem:UITabBar.new]).to.beTruthy();
    expect([selector shouldSelectItem:UINavigationBar.new]).to.beFalsy();
}

- (void)testSelectViewWithIndirectSuperview {
    CASStyleSelector *parentSelector = CASStyleSelector.new;
    parentSelector.objectClass = UIControl.class;
    parentSelector.parent = YES;

    CASStyleSelector *selector = CASStyleSelector.new;
    selector.objectClass = UISlider.class;
    selector.parentSelector = parentSelector;

    UIControl *control = UIControl.new;
    UISlider *slider = UISlider.new;
    [control addSubview:slider];

    expect(selector.stringValue).to.equal(@"UIControl UISlider");
    expect([selector shouldSelectItem:UIView.new]).to.beFalsy();
    expect([selector shouldSelectItem:slider]).to.beTruthy();

    //add view inbetween control and slider
    UIButton *button = UIButton.new;
    button.cas_styleClass = @"styleClassIrrelevantInThisCase";
    [control addSubview:button];
    [button addSubview:slider];

    expect([selector shouldSelectItem:slider]).to.beTruthy();
}

- (void)testSelectViewWithDirectSuperviewOnly {
    CASStyleSelector *parentSelector = CASStyleSelector.new;
    parentSelector.objectClass = UIControl.class;
    parentSelector.parent = YES;

    CASStyleSelector *selector = CASStyleSelector.new;
    selector.objectClass = UISlider.class;
    selector.shouldSelectIndirectSuperview = NO;
    selector.parentSelector = parentSelector;

    UIControl *control = UIControl.new;
    UISlider *slider = UISlider.new;
    [control addSubview:slider];

    expect(selector.stringValue).to.equal(@"UIControl > UISlider");
    expect([selector shouldSelectItem:UIView.new]).to.beFalsy();
    expect([selector shouldSelectItem:slider]).to.beTruthy();

    //add view inbetween control and slider
    UIButton *button = UIButton.new;
    button.cas_styleClass = @"styleClassIrrelevantInThisCase";
    [control addSubview:button];
    [button addSubview:slider];

    expect([selector shouldSelectItem:slider]).to.beFalsy();
}

- (void)testSelectViewWithStyleClass {
    CASStyleSelector *selector = CASStyleSelector.new;
    selector.styleClass = @"big";

    selector.objectClass = UIView.class;
    UIView *view = UIView.new;
    expect(selector.stringValue).to.equal(@"UIView.big");
    expect([selector shouldSelectItem:view]).to.beFalsy();
    view.cas_styleClass = @"big";
    expect([selector shouldSelectItem:view]).to.beTruthy();

    selector.objectClass = UITabBar.class;

    UITabBar *tabBar = UITabBar.new;
    expect(selector.stringValue).to.equal(@"UITabBar.big");
    expect([selector shouldSelectItem:tabBar]).to.beFalsy();
    tabBar.cas_styleClass = @"big";
    expect([selector shouldSelectItem:tabBar]).to.beTruthy();
}

- (void)testSelectViewWithSubclassMatch {
    CASStyleSelector *selector = CASStyleSelector.new;
    selector.objectClass = UIControl.class;
    selector.shouldSelectSubclasses = YES;

    expect(selector.stringValue).to.equal(@"^UIControl");
    expect([selector shouldSelectItem:UIControl.new]).to.beTruthy();
    expect([selector shouldSelectItem:UIButton.new]).to.beTruthy();
    expect([selector shouldSelectItem:UIView.new]).to.beFalsy();
    expect([selector shouldSelectItem:UINavigationBar.new]).to.beFalsy();
}

- (void)testSelectViewWithComplexMixedMatchers {
    CASStyleSelector *parentSelector3 = CASStyleSelector.new;
    parentSelector3.objectClass = UIButton.class;
    parentSelector3.styleClass = @"top";
    parentSelector3.parent = YES;

    CASStyleSelector *parentSelector2 = CASStyleSelector.new;
    parentSelector2.objectClass = UIView.class;
    parentSelector2.shouldSelectSubclasses = YES;
    parentSelector2.shouldSelectIndirectSuperview = NO;
    parentSelector2.parent = YES;
    parentSelector2.parentSelector = parentSelector3;

    CASStyleSelector *parentSelector1 = CASStyleSelector.new;
    parentSelector1.objectClass = UIControl.class;
    parentSelector1.styleClass = @"mid";
    parentSelector1.parent = YES;
    parentSelector1.parentSelector = parentSelector2;

    CASStyleSelector *selector = CASStyleSelector.new;
    selector.objectClass = UISlider.class;
    selector.shouldSelectIndirectSuperview = NO;
    selector.parentSelector = parentSelector1;

    expect(selector.stringValue).to.equal(@"UIButton.top > ^UIView UIControl.mid > UISlider");

    // view heirarchy 1
    UIButton *topButton = UIButton.new;
    topButton.cas_styleClass = @"top";

    UIView *view = UIView.new;
    [topButton addSubview:view];

    UIControl *midControl = UIControl.new;
    midControl.cas_styleClass = @"mid";
    [view addSubview:midControl];

    UISlider *slider = UISlider.new;
    [midControl addSubview:slider];

    expect(CASStringViewHierarchyFromView(slider)).to.equal(@"UIButton.top > UIView > UIControl.mid > UISlider");
    expect([selector shouldSelectItem:slider]).to.beTruthy();

    // view heirarchy 2
    [view removeFromSuperview];
    expect(CASStringViewHierarchyFromView(slider)).to.equal(@"UIView > UIControl.mid > UISlider");
    expect([selector shouldSelectItem:slider]).to.beFalsy();

    // view heirarchy 3
    UIButton *button = UIButton.new;
    [topButton addSubview:button];

    CASExampleView *exampleView = CASExampleView.new;
    [button addSubview:exampleView];

    [exampleView addSubview:view];
    expect(CASStringViewHierarchyFromView(slider)).to.equal(@"UIButton.top > UIButton > CASExampleView > UIView > UIControl.mid > UISlider");
    expect([selector shouldSelectItem:slider]).to.beTruthy();
}

- (void)testSelectViewWithAlternativeParents {
    CASStyleSelector *parentSelector2 = CASStyleSelector.new;
    parentSelector2.objectClass = UIButton.class;
    parentSelector2.styleClass = @"top";
    parentSelector2.parent = YES;

    CASStyleSelector *parentSelector1 = CASStyleSelector.new;
    parentSelector1.objectClass = CASExampleViewController.class;
    parentSelector1.shouldSelectIndirectSuperview = NO;
    parentSelector1.parent = YES;
    parentSelector1.parentSelector = parentSelector2;

    CASStyleSelector *selector = CASStyleSelector.new;
    selector.objectClass = UISlider.class;
    selector.shouldSelectIndirectSuperview = YES;
    selector.parentSelector = parentSelector1;

    expect(selector.stringValue).to.equal(@"UIButton.top > CASExampleViewController UISlider");

    // view heirarchy 1
    UIButton *topButton = UIButton.new;
    topButton.cas_styleClass = @"top";

    CASExampleViewController *viewController = CASExampleViewController.new;
    [topButton addSubview:viewController.view];

    UIView *view = UIView.new;
    [viewController.view addSubview:view];

    UISlider *slider = UISlider.new;
    [view addSubview:slider];

    expect(viewController.view.cas_alternativeParent).to.beIdenticalTo(viewController);
    expect(CASStringViewHierarchyFromView(slider)).to.equal(@"UIButton.top > CASExampleView > UIView > UISlider");

    expect([selector shouldSelectItem:slider]).to.beTruthy();
}

SpecEnd