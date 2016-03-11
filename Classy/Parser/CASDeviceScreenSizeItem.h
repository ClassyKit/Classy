//
//  Created by Ole Gammelgaard Poulsen on 05/04/14.
//  Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CASDeviceSelectorItem.h"
#import "CASDeviceSelector.h"


@interface CASDeviceScreenSizeItem : NSObject <CASDeviceSelectorItem>

@property (nonatomic, assign) float value;
@property (nonatomic, assign) CASRelation relation;
@property(nonatomic, assign) CASDeviceSelectorScreenDimension dimension;

@end
