//
//  MODRendererSpec.m
//  Mod
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODStyler.h"
#import "UIColor+MODAdditions.h"

SpecBegin(MODStyler)

it(@"should set basic properties", ^{
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIView-Basic.mod" ofType:nil];
    MODStyler *styler = [[MODStyler alloc] initWithFilePath:filePath error:nil];
    UIView *view = UIView.new;
    [styler styleView:view];


    //expect(view.class.superclass).to.equal(@"");
    //expect(view.backgroundColor.mod_hexValue).to.equal(@"#A2A2A2");
});

SpecEnd