//
//  MODStyler.h
//  Mod
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MODStyler : NSObject

- (id)initWithFilePath:(NSString *)filePath error:(NSError **)error;
- (void)styleView:(UIView *)view;

@end
