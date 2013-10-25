//
//  CASUIAppearanceSpec.m
//  ClassyTests
//
//  Created by Jonas Budelmann on 25/10/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "Classy.h"

SpecBegin(CASUIAppearance)

- (void)testUIButtonAppearance {
    NSError *error = nil;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIAppearance-Basic.cas" ofType:nil];
    CASStyler *styler = CASStyler.new;
    [styler setFilePath:filePath error:&error];

    expect(error).to.beNil();
}

SpecEnd