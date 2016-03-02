//
//  NSDictionary+KeyValues.m
//  Classy
//
//  Created by Mihail Gerasimenko on 3/2/16.
//  Copyright © 2016 Zeta Project Berlin Gmbh. All rights reserved.
//

#import "NSDictionary+KeyValues.h"

@implementation NSDictionary (CASKeyValues)

- (NSArray *)cas_keyValues
{
    NSArray *allKeys = self.allKeys;
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:allKeys.count];
    for (NSString *key in allKeys) {
        NSDictionary *keyValue = [NSDictionary dictionaryWithObjectsAndKeys:key, @"key", [self objectForKey:key], @"value", nil];
        [result addObject:keyValue];
    }
    return [result copy];
}

- (NSArray *)cas_sortedKeyValues
{
    NSSortDescriptor *sortByKey = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    return [self.cas_keyValues sortedArrayUsingDescriptors:@[sortByKey]];
}

@end
