//
//  CASDeviceOSVersionItem.m
//  Classy
//
//  Created by Jonas Budelmann on 25/11/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASDeviceOSVersionItem.h"
#import "CASUtilities.h"
#import "CASDeviceSelector.h"

@implementation CASDeviceOSVersionItem

- (BOOL)isValid {
    switch (self.relation) {
        case CASRelationLessThan:
            return CASDeviceSystemVersionIsLessThan(self.version);
        case CASRelationLessThanOrEqual:
            return CASDeviceSystemVersionIsLessThanOrEqualTo(self.version);
        case CASRelationEqual:
            return CASDeviceSystemVersionIsEqualTo(self.version);
        case CASRelationGreaterThanOrEqual:
            return CASDeviceSystemVersionIsGreaterThanOrEqualTo(self.version);
        case CASRelationGreaterThan:
            return CASDeviceSystemVersionIsGreaterThan(self.version);
        default:
            NSAssert(NO, @"Invalid ralation");
            return NO;
    }
}

- (NSString *)stringValue {
    return [NSString stringWithFormat:@"(version:%@%@)", [CASDeviceSelector stringFromRelation:self.relation], self.version];
}

@end
