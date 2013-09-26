//
//  MODToken.h
//  Mod
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MODTokenType) {
    MODTokenTypeIndent,
    MODTokenTypeOutdent,
    MODTokenTypeEOS,
    MODTokenTypeSemiColon,
    MODTokenTypeNewline,
    MODTokenTypeOpeningBrace,
    MODTokenTypeClosingBrace,
    MODTokenTypeColor,
    MODTokenTypeString,
    MODTokenTypeUnit,
    MODTokenTypeBoolean,
    MODTokenTypeRef,
    MODTokenTypeOperator,
    MODTokenTypeSpace,
    MODTokenTypeSelector,
};

@interface MODToken : NSObject

/**
 *  The type of the token, may not represent the true type which is determined in context of other tokens
 */
@property (nonatomic, assign, readonly) MODTokenType type;

/**
 *  The value of the token, could be a boxed primitive or a `NSString`, `UIColor`, ...
 */
@property (nonatomic, strong) id value;

/**
 *  The line number at which the token appeared in the style file, used for debug and error messages
 */
@property (nonatomic, assign) NSInteger lineNumber;

/**
 *  Factory method for creating tokens with a particular `MODTokenType`
 */
+ (instancetype)tokenOfType:(MODTokenType)type;

/**
 *  Returns a `NSString` representation of a `MODTokenType`
 *  Mainly used for debug output
 *
 *  @param type The `MODTokenType` to convert to a `NSString`
 *
 *  @return a `NSString` representing the passed `MODTokenType`
 */
+ (NSString *)stringForType:(MODTokenType)type;

/**
 *  Returns whether reciever is a whitespace token or not
 *
 *  @return `YES` if reciever is one of the following types indent, outdent, space, new line.
 */
- (BOOL)isWhitespace;

/**
 *  Returns whether reciever's value is equal to the given value
 *
 *  @param string the value for comparison
 *
 *  @return `YES` if reciever is equal to the given value
 */
- (BOOL)valueIsEqualTo:(id)value;

/**
 *  Returns whether the reciever could be a valid selector token.
 *  However context will determine if it is definitely a selector
 *
 *  @return `YES` if it is possible that the reciever is a selector
 */
- (BOOL)isPossiblySelector;

@end
