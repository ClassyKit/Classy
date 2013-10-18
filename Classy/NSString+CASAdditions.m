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

@end
