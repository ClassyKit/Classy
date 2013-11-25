//
//  CASDeviceOSVersionItem.m
//  Classy
//
//  Created by Jonas Budelmann on 25/11/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASDeviceOSVersionItem.h"
#import "CASUtilities.h"

@implementation CASDeviceOSVersionItem

- (NSString *)relationString {
    switch (self.relation) {
        case CASRelationLessThan:
            return @"<";
        case CASRelationLessThanOrEqual:
            return @"<=";
        case CASRelationEqual:
            return @"";
        case CASRelationGreaterThanOrEqual:
            return @">=";
        case CASRelationGreaterThan:
            return @">";
    }
}

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
    }
}

- (NSString *)stringValue {
    return [NSString stringWithFormat:@"(version:%@%@)", self.relationString, self.version];
}

@end
