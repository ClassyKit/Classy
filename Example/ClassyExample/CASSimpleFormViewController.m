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
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    v.backgroundColor = [UIColor redColor];
    v.cas_styleClass = @"shadow-view";
    [self.view addSubview:v];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 300, self.view.bounds.size.width - 100, 300)];
    textLabel.text = @"Quick lazy Swift jumps over the lazy iOS/OS X developer's leg.";
    textLabel.numberOfLines = 0;
    textLabel.cas_styleClass = @"text-label";
    [self.view addSubview:textLabel];
}

@end
