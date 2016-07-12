//
//  CASStyleMediaSelector.h
//  Classy
//
//  Created by Jonas Budelmann on 24/11/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CASDeviceTypeItem.h"
#import "CASDeviceOSVersionItem.h"

typedef NS_ENUM(NSUInteger, CASDeviceSelectorScreenDimension) {
    CASDeviceSelectorScreenDimensionWidth = 0,
    CASDeviceSelectorScreenDimensionHeight,
};

@interface CASDeviceSelector : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSArray *items;

+ (NSString *)stringFromRelation:(CASRelation)relation;

- (void)addItems:(NSArray *)items;
- (void)addDeviceType:(CASDeviceType)deviceType;
- (BOOL)addOSVersion:(NSString *)versionExpression;
- (BOOL)addScreenSize:(NSString *)sizeExpression dimension:(CASDeviceSelectorScreenDimension)dimension;

- (BOOL)isValid;
- (NSString *)stringValue;

@end
