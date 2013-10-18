//
//  NSRegularExpression+CASAdditions.h
//  Classy
//
//  Created by Jonas Budelmann on 17/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSRegularExpression *CASRegex(NSString *patternFormat, ...) NS_FORMAT_FUNCTION(1,2);

@interface NSRegularExpression (CASAdditions)

- (NSUInteger)cas_replaceMatchesInString:(NSMutableString *)string withTemplate:(NSString *)templ;

@end
