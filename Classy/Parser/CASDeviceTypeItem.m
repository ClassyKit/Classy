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
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
    } else {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    }
}

- (NSString *)stringValue {
    if (self.deviceType == CASDeviceTypePhone) {
        return @"phone";
    }
    return @"pad";
}

@end
