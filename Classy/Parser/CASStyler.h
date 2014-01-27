//
//  CASStyler.h
//  Classy
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CASObjectClassDescriptor.h"
#import "CASStyleableItem.h"

@interface CASStyler : NSObject

/**
 *  Singleton instance
 */
+ (instancetype)defaultStyler;

@property (nonatomic, copy) NSDictionary *variables;

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
 *  Apply any applicable styles to a CASStyleableItem instance, from low to high precendence
 *
 *  @param item `CASStyleableItem` to apply styles to
 */
- (void)styleItem:(id<CASStyleableItem>)item;

/**
 *  Returns a cached CASObjectClassDescriptor if it exists or creates one
 */
- (CASObjectClassDescriptor *)objectClassDescriptorForClass:(Class)aClass;

/**
 *  Schedule update for styleable item.
 *  This ensures we only update an item once per run loop
 *
 *  @param item CASStyleableItem to coalesce update calls
 */
- (void)scheduleUpdateForItem:(id<CASStyleableItem>)item;

/**
 *  Unschedule update for styleable item
 *
 *  @param item CASStyleableItem that no longer needs updating
 */
- (void)unscheduleUpdateForItem:(id<CASStyleableItem>)item;

@end
