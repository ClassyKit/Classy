//
//  CASCustomViewSpec.m
//  ClassyTests
//
//  Created by Jonas Budelmann on 25/10/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "Classy.h"
#import "CASExampleView.h"

SpecBegin(CASCustomView)

- (void)testSetCustomProperties {
    CASStyler *styler = CASStyler.new;
    styler.filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"CustomView-Basic.cas" ofType:nil];
    CASExampleView *exampleView = CASExampleView.new;
    [styler styleView:exampleView];

    expect(exampleView.testCGFloat).to.equal(4.5);
    expect(exampleView.testBOOL).to.equal(YES);
    expect(exampleView.testNSInteger).to.equal(-999);
    expect(exampleView.testNSUInteger).to.equal(1000);
    expect(exampleView.testInt).to.equal(345);
}

SpecEnd