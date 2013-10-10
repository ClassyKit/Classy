//
//  NSRegularExpression+MODAdditions.h
//  Mod
//
//  Created by Jonas Budelmann on 17/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSRegularExpression *MODRegex(NSString *patternFormat, ...) NS_FORMAT_FUNCTION(1,2);

@interface NSRegularExpression (MODAdditions)

- (NSUInteger)mod_replaceMatchesInString:(NSMutableString *)string withTemplate:(NSString *)templ;

@end
