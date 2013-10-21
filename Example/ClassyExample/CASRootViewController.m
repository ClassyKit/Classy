//
//  CASRootViewController.m
//  ClassyExample
//
//  Created by Jonas Budelmann on 21/10/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "CASRootViewController.h"

#import "CASSimpleFormViewController.h"
#import "CASCatalogViewController.h"

static NSString * const CASRootCellReuseIdentifier = @"CASRootCellReuseIdentifier";

@interface CASRootViewController ()

@property (nonatomic, strong) NSArray *exampleControllers;

@end

@implementation CASRootViewController

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.title = @"Examples";

    self.exampleControllers = @[
        CASSimpleFormViewController.new,
        CASCatalogViewController.new,
    ];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CASRootCellReuseIdentifier];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = self.exampleControllers[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CASRootCellReuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = viewController.title;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.exampleControllers.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = self.exampleControllers[indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end