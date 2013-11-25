//
//  CASDeviceTypeItem.h
//  Classy
//
//  Created by Jonas Budelmann on 25/11/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CASDeviceSelectorItem.h"


typedef NS_ENUM(NSInteger, CASDeviceType) {
    CASDeviceTypePhone = 0,
    CASDeviceTypePad = 1,
};

@interface CASDeviceTypeItem : NSObject <CASDeviceSelectorItem>

@property (nonatomic, assign) CASDeviceType deviceType;

@end
