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

@interface CASDeviceSelector : NSObject

@property (nonatomic, strong, readonly) NSArray *items;

- (void)addItems:(NSArray *)items;
- (void)addDeviceType:(CASDeviceType)deviceType;
- (BOOL)addOSVersion:(NSString *)version;

- (BOOL)isValid;
- (NSString *)stringValue;

@end
