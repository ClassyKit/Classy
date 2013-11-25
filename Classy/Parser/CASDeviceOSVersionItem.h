//
//  CASDeviceOSVersionItem.h
//  Classy
//
//  Created by Jonas Budelmann on 25/11/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CASDeviceSelectorItem.h"

@interface CASDeviceOSVersionItem : NSObject <CASDeviceSelectorItem>

@property (nonatomic, copy) NSString *version;
@property (nonatomic, assign) CASRelation relation;

@end
