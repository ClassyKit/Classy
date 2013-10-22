//
//  CASStyler.h
//  Classy
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CASViewClassDescriptor.h"

@interface CASStyler : NSObject

/**
 *  Singleton instance
 */
+ (instancetype)defaultStyler;

/**
 *  File path which contains style data
 */
@property (nonatomic, copy) NSString *filePath;

/**
 *  File path to watch for changes.
 *  Only use for debugging on simulator
 */
@property (nonatomic, copy) NSString *watchFilePath;

/**
 *  Set file path location of styling data and report any errors
 *
 *  @param filePath The location of the style data
 *  @param error    The error that occurred while parsing the filePath
 */
- (void)setFilePath:(NSString *)filePath error:(NSError **)error;

/**
 *  Apply any applicable styles to view instance, from low to high precendence
 *
 *  @param view `UIView` to apply styles to
 */
- (void)styleView:(UIView *)view;

/**
 *  Returns a cached CASViewClassDescriptor if it exists or creates one
 */
- (CASViewClassDescriptor *)viewClassDescriptorForClass:(Class)class;

@end
