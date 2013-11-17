//
//  CASExampleViewController.m
//  ClassyTests
//
//  Created by Jonas Budelmann on 18/11/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "CASExampleViewController.h"
#import "CASExampleView.h"

@implementation CASExampleViewController

- (void)loadView {
    self.view = CASExampleView.new;
}

@end
