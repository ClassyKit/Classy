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

- (BOOL)addOSVersion:(NSString *)versionExpression {
    NSString *valueString = [self valueFromExpression:versionExpression];
    NSString *relationString = [versionExpression substringToIndex:versionExpression.length - valueString.length];

    CASRelation relation = [self relationFromExpression:relationString];
    if (relation == CASRelationUndefined) return NO;

    CASDeviceOSVersionItem *item = CASDeviceOSVersionItem.new;
    item.version = valueString;
    item.relation = relation;
    [_items addObject:item];

    return YES;
}

- (BOOL)addScreenSize:(NSString *)sizeExpression dimension:(CASDeviceSelectorScreenDimension)dimension {
    NSString *valueString = [self valueFromExpression:sizeExpression];
    NSString *relationString = [sizeExpression substringToIndex:sizeExpression.length - valueString.length];

    CASRelation relation = [self relationFromExpression:relationString];
    if (relation == CASRelationUndefined) return NO;

    CASDeviceScreenSizeItem *item = CASDeviceScreenSizeItem.new;
    item.value = valueString.floatValue;
    item.relation = relation;
    item.dimension = dimension;
    [_items addObject:item];

    return YES;
}

- (NSString *)valueFromExpression:(NSString *)relation {
    NSCharacterSet *equalityCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@">=<"];
    NSString *valueString = [relation cas_stringByTrimmingLeadingCharactersInSet:equalityCharacterSet];
    return valueString;
}

- (CASRelation)relationFromExpression:(NSString *)expression {
    CASRelation relation = CASRelationEqual;
    if ([expression isEqualToString:@"<"]) {
        relation = CASRelationLessThan;
    } else if ([expression isEqualToString:@"<="]) {
        relation = CASRelationLessThanOrEqual;
    } else if ([expression isEqualToString:@"=="]) {
        relation = CASRelationEqual;
    } else if ([expression isEqualToString:@">="]) {
        relation = CASRelationGreaterThanOrEqual;
    } else if ([expression isEqualToString:@">"]) {
        relation = CASRelationGreaterThan;
    } else if (relation == CASRelationEqual && expression.length) {
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

+ (NSString *)stringFromRelation:(CASRelation)relation {
    switch (relation) {
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
        case CASRelationUndefined:
            NSAssert(NO, @"Relation should not be undefined");
            return nil;
        default:
            NSAssert(NO, @"Relation should not be an undefined enum value");
            return nil;
    }
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (nil != self) {
        _items = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(items))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.items forKey:NSStringFromSelector(@selector(items))];
}

@end
