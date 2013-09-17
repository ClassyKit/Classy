//
//  NSRegularExpression+MODAdditions.m
//  Mod
//
//  Created by Jonas Budelmann on 17/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "NSRegularExpression+MODAdditions.h"

extern NSRegularExpression *MODRegex(NSString *pattern) {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSCAssert(error == nil, @"Could not create regex from pattern: %@", pattern);
    if (error) {
        NSLog(@"error: %@", error);
    }
    return regex;
}

@implementation NSRegularExpression (MODAdditions)

- (NSUInteger)mod_replaceMatchesInString:(NSMutableString *)string withTemplate:(NSString *)templ {
    return [self replaceMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:templ];
}

- (NSString *)mod_firstMatchInString:(NSString *)string {
    NSTextCheckingResult *result = [self firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    if (result) {
        return [string substringWithRange:result.range];
    }
    return nil;
}

@end
