//
//  NSString+CASAdditions.m
//  Classy
//
//  Created by Jonas Budelmann on 14/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "NSString+CASAdditions.h"

@implementation NSString (CASAdditions)

- (NSString *)cas_stringByCapitalizingFirstLetter {
    if (!self.length) return self;
    return [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self substringToIndex:1] capitalizedString]];
}

- (NSString *)cas_stringByTrimmingWhitespace {
    return [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
}

- (NSString *)cas_stringByCamelCasing {
    NSArray *components = [self componentsSeparatedByString:@"-"];
    if (components.count <= 1) return self;

    NSMutableString *camelCasedString = [NSMutableString string];
    for (NSUInteger i = 0; i < components.count; i++) {
        if (i == 0) {
            [camelCasedString appendString:components[i]];
        } else {
            [camelCasedString appendString:[components[i] cas_stringByCapitalizingFirstLetter]];
        }
    }
    return camelCasedString;
}

- (NSString *)cas_stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet {
    NSInteger i = 0;
    while ((i < self.length) && [characterSet characterIsMember:[self characterAtIndex:i]]) {
        i++;
    }
    return [self substringFromIndex:i];
}

@end
