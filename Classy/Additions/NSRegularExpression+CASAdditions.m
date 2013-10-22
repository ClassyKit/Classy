//
//  NSRegularExpression+CASAdditions.m
//  Classy
//
//  Created by Jonas Budelmann on 17/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "NSRegularExpression+CASAdditions.h"
#import "CASUtilities.h"

extern NSRegularExpression *CASRegex(NSString *patternFormat, ...) {
    va_list args;
    va_start(args, patternFormat);
    NSString *pattern = [[NSString alloc] initWithFormat:patternFormat arguments:args];
    va_end(args);

    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSCAssert(error == nil, @"Could not create regex from pattern %@", pattern);
    if (error) {
        CASLog(@"error %@", error);
    }
    return regex;
}

@implementation NSRegularExpression (CASAdditions)

- (NSUInteger)cas_replaceMatchesInString:(NSMutableString *)string withTemplate:(NSString *)templ {
    return [self replaceMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:templ];
}

@end
