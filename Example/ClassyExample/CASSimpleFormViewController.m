//
//  CASSimpleFormViewController.m
//  ClassyExample
//
//  Created by Jonas Budelmann on 21/10/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "CASSimpleFormViewController.h"
#import <Classy/Classy.h>

@interface CASSimpleFormViewController ()

@end

@implementation CASSimpleFormViewController

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.title = @"Simple Form";

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor greenColor];
    NSArray *classes = @[@"caches",@"documents",@"bundle"];
    
    float yOff = 100;
    for( NSString * class in classes )
    {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        b.cas_styleClass = class;
        b.frame = CGRectMake(10, yOff, self.view.bounds.size.width-20, 40);
        [self.view addSubview:b];
        yOff += CGRectGetHeight(b.frame) + 10;
    }
}

@end
