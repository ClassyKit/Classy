//
//  MODStyler.m
//  Mod
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODStyler.h"
#import "MODParser.h"

@interface MODStyler ()

@property (nonatomic, strong) NSArray *styleGroups;

@end

@implementation MODStyler

- (id)initWithFilePath:(NSString *)filePath error:(NSError **)error {
    self = [super init];
    if (!self) return nil;

    self.styleGroups = [MODParser stylesFromFilePath:filePath error:error];

    return self;
}

- (void)styleView:(UIView *)view {
    
}

@end
