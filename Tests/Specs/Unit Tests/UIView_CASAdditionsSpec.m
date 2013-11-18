//
//  UIView_CASAdditionsSpec.m
//  ClassyTests
//
//  Created by Jonas Budelmann on 18/11/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "UIView+CASAdditions.h"

@interface TestView : UIView

@property (nonatomic, assign) NSInteger updateStylingCount;
@property (nonatomic, assign) NSInteger setNeedsUpdateStylingCount;

@end

@implementation TestView

- (void)cas_updateStyling {
    [super cas_updateStyling];

    self.updateStylingCount++;
}

- (void)cas_setNeedsUpdateStyling {
    [super cas_setNeedsUpdateStyling];

    self.setNeedsUpdateStylingCount++;
}

@end

SpecBegin(UIView_CASAdditions)

//test coalescing of styling calls
- (void)testStyleUpdateCalledOnce {
    TestView *view = TestView.new;

    view.cas_styleClass = @"test";

    UIWindow *window = UIWindow.new;
    window.hidden = NO;
    [window addSubview:view];

    view.cas_styleClass = @"change";

    // Run the loop
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    expect(view.updateStylingCount).to.equal(1);
    expect(view.setNeedsUpdateStylingCount).to.equal(3);
}

SpecEnd