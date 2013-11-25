//
//  CASStyleMediaSelector.m
//  Classy
//
//  Created by Jonas Budelmann on 24/11/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASDeviceSelector.h"
#import "NSString+CASAdditions.h"

@implementation CASDeviceSelector {
    NSMutableArray *_items;
}

- (id)init {
    self = [super init];
    if (!self) return nil;

    _items = NSMutableArray.new;

    return self;
}

- (NSArray *)items {
    return _items;
}

- (void)addItems:(NSArray *)items {
    [_items addObjectsFromArray:items];
}

- (void)addDeviceType:(CASDeviceType)deviceType {
    CASDeviceTypeItem *item = CASDeviceTypeItem.new;
    item.deviceType = deviceType;
    [_items addObject:item];
}

- (BOOL)addOSVersion:(NSString *)version {
    CASRelation relation = CASRelationEqual;

    NSCharacterSet *equalityCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@">=<"];
    NSString *versionNumberString = [version cas_stringByTrimmingLeadingCharactersInSet:equalityCharacterSet];
    NSString *relationString = [version substringToIndex:version.length - versionNumberString.length];

    if ([relationString isEqualToString:@"<"]) {
        relation = CASRelationLessThan;
    } else if ([relationString isEqualToString:@"<="]) {
        relation = CASRelationLessThanOrEqual;
    } else if ([relationString isEqualToString:@"=="]) {
        relation = CASRelationEqual;
    } else if ([relationString isEqualToString:@">="]) {
        relation = CASRelationGreaterThanOrEqual;
    } else if ([relationString isEqualToString:@">"]) {
        relation = CASRelationGreaterThan;
    } else if (relation == CASRelationEqual && relationString.length) {
        return NO;
    }

    CASDeviceOSVersionItem *item = CASDeviceOSVersionItem.new;
    item.version = versionNumberString;
    item.relation = relation;
    [_items addObject:item];

    return YES;
}

- (BOOL)isValid {
    for (id<CASDeviceSelectorItem> item in self.items) {
        if (!item.isValid) {
            return NO;
        }
    }
    return YES;
}

- (NSString *)stringValue {
    NSMutableString *string = NSMutableString.new;

    [self.items enumerateObjectsUsingBlock:^(id<CASDeviceSelectorItem> item, NSUInteger idx, BOOL *stop) {
        [string appendString:item.stringValue];
        if (idx != self.items.count - 1) {
            [string appendString:@" and "];
        }
    }];

    return string;
}

@end
