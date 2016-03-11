//
//  CASDeviceTypeItem.m
//  Classy
//
//  Created by Jonas Budelmann on 25/11/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASDeviceTypeItem.h"

@implementation CASDeviceTypeItem

- (BOOL)isValid {
    if (self.deviceType == CASDeviceTypePhone) {
        return UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
    } else {
        return UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad;
    }
}

- (NSString *)stringValue {
    if (self.deviceType == CASDeviceTypePhone) {
        return @"phone";
    }
    return @"pad";
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (nil != self) {
        self.deviceType = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(deviceType))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.deviceType forKey:NSStringFromSelector(@selector(deviceType))];
}

@end
