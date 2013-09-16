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

@property (nonatomic, strong) MODParser *parser;

@end

@implementation MODStyler

- (id)initWithFilePath:(NSString *)filePath error:(NSError **)error {
    self = [super init];
    if (!self) return nil;

    self.parser = [[MODParser alloc] initWithFilePath:filePath error:error];
    [self.parser parse];
    return self;
}

- (void)styleView:(UIView *)view {
    
}

@end
