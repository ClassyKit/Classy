//
//  MODStyler.h
//  Mod
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MODViewClassDescriptor.h"

@interface MODStyler : NSObject

/**
 *  Create styler with filePath
 */
- (id)initWithFilePath:(NSString *)filePath error:(NSError **)error;

/**
 *  Apply any applicable styles to view instance, from low to high precendence
 *
 *  @param view `UIView` to apply styles to
 */
- (void)styleView:(UIView *)view;

/**
 *  Returns a cached MODViewClassDescriptor if it exists or creates one
 */
- (MODViewClassDescriptor *)viewClassDescriptorForClass:(Class)class;

@end
