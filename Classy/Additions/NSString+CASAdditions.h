//
//  NSString+CASAdditions.h
//  Classy
//
//  Created by Jonas Budelmann on 14/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CASAdditions)

- (NSString *)cas_stringByCapitalizingFirstLetter;
- (NSString *)cas_stringByTrimmingWhitespace;
- (NSString *)cas_stringByCamelCasing;
- (NSString *)cas_stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)cas_stringByAddingStyleClass:(NSString *)styleClass;
- (NSString *)cas_stringByRemovingStyleClass:(NSString *)styleClass;

@end
