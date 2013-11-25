//
//  CASDeviceSelectorItem.h
//  Classy
//
//  Created by Jonas Budelmann on 25/11/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CASRelation) {
    CASRelationLessThan = -2,
    CASRelationLessThanOrEqual = -1,
    CASRelationEqual = 0,
    CASRelationGreaterThanOrEqual = 1,
    CASRelationGreaterThan = 2,
};

@protocol CASDeviceSelectorItem <NSObject>

- (BOOL)isValid;
- (NSString *)stringValue;

@end