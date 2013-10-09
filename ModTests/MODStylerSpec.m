//
//  MODRendererSpec.m
//  Mod
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODStyler.h"
#import "UIColor+MODAdditions.h"
#import "MODStyleSelector.h"

@interface MODStyler ()
@property (nonatomic, strong) NSMutableArray *styles;
@end

SpecBegin(MODStyler)

it(@"should sort selectors by precedence", ^{
    NSError *error = nil;
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Properties-Basic.mod" ofType:nil];
    MODStyler *styler = [[MODStyler alloc] initWithFilePath:filePath error:&error];
    expect(error).to.beNil();

    expect([styler.styles[0] stringValue]).to.equal(@"UIView.bordered");
    expect([styler.styles[1] stringValue]).to.equal(@"UIControl.border");
    expect([styler.styles[2] stringValue]).to.equal(@"UIButton[state:selected] UIControl");
    expect([styler.styles[3] stringValue]).to.equal(@"UINavigationBar UIButton");
    expect([styler.styles[4] stringValue]).to.equal(@"UISlider");
});

xit(@"should set basic properties", ^{
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"UIView-Basic.mod" ofType:nil];
    MODStyler *styler = [[MODStyler alloc] initWithFilePath:filePath error:nil];
    UIView *view = UIView.new;
    [styler styleView:view];

    expect(view.backgroundColor.mod_hexValue).to.equal(@"#A2A2A2");
});

SpecEnd