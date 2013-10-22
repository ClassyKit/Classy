//
//  CASCatalogViewController.m
//  ClassyExample
//
//  Created by Jonas Budelmann on 21/10/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "CASCatalogViewController.h"

@interface CASCatalogViewController ()

@end

@implementation CASCatalogViewController

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.title = @"Catalog";

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor greenColor];
}

@end
