//
//  CASStyleMediaSelector.m
//  Classy
//
//  Created by Jonas Budelmann on 24/11/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASDeviceSelector.h"
#import "NSString+CASAdditions.h"
#import "CASDeviceScreenSizeItem.h"

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

- (BOOL)addOSVersion:(NSString *)versionConstraint {
    NSString *valueString = [self valueFromConstraint:versionConstraint];
    NSString *relationString = [versionConstraint substringToIndex:versionConstraint.length - valueString.length];

    CASRelation relation = [self relationFromConstraint:relationString];
    if (relation == CASRelationUndefined) return NO;

    CASDeviceOSVersionItem *item = CASDeviceOSVersionItem.new;
    item.version = valueString;
    item.relation = relation;
    [_items addObject:item];

    return YES;
}

- (BOOL)addScreenSize:(NSString *)sizeConstraint dimension:(CASDeviceSelectorScreenDimension)dimension {
    NSString *valueString = [self valueFromConstraint:sizeConstraint];
    NSString *relationString = [sizeConstraint substringToIndex:sizeConstraint.length - valueString.length];

    CASRelation relation = [self relationFromConstraint:relationString];
    if (relation == CASRelationUndefined) return NO;

    CASDeviceScreenSizeItem *item = CASDeviceScreenSizeItem.new;
    item.value = valueString.floatValue;
    item.relation = relation;
    item.dimension = dimension;
    [_items addObject:item];

    return YES;
}

- (NSString *)valueFromConstraint:(NSString *)relation {
    NSCharacterSet *equalityCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@">=<"];
    NSString *valueString = [relation cas_stringByTrimmingLeadingCharactersInSet:equalityCharacterSet];
    return valueString;
}

- (CASRelation)relationFromConstraint:(NSString *)constraintString {
    CASRelation relation = CASRelationEqual;
    if ([constraintString isEqualToString:@"<"]) {
        relation = CASRelationLessThan;
    } else if ([constraintString isEqualToString:@"<="]) {
        relation = CASRelationLessThanOrEqual;
    } else if ([constraintString isEqualToString:@"=="]) {
        relation = CASRelationEqual;
    } else if ([constraintString isEqualToString:@">="]) {
        relation = CASRelationGreaterThanOrEqual;
    } else if ([constraintString isEqualToString:@">"]) {
        relation = CASRelationGreaterThan;
    } else if (relation == CASRelationEqual && constraintString.length) {
       relation = CASRelationUndefined;
    }
    return relation;
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
