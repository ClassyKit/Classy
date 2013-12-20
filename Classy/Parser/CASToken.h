//
//  CASToken.h
//  Classy
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CASTokenType) {
    CASTokenTypeUnknown,
    CASTokenTypeIndent,
    CASTokenTypeOutdent,
    CASTokenTypeEOS,
    CASTokenTypeSemiColon,
    CASTokenTypeCarat,
    CASTokenTypeNewline,
    CASTokenTypeLeftSquareBrace,
    CASTokenTypeRightSquareBrace,
    CASTokenTypeLeftCurlyBrace,
    CASTokenTypeRightCurlyBrace,
    CASTokenTypeLeftRoundBrace,
    CASTokenTypeRightRoundBrace,
    CASTokenTypeColor,
    CASTokenTypeString,
    CASTokenTypeUnit,
    CASTokenTypeBoolean,
    CASTokenTypeRef,
    CASTokenTypeOperator,
    CASTokenTypeSpace,
    CASTokenTypeSelector,
};

@interface CASToken : NSObject

/**
 *  The type of the token, may not represent the true type which is determined in context of other tokens
 */
@property (nonatomic, assign, readonly) CASTokenType type;

/**
 *  The value of the token, could be a boxed primitive or a `NSString`, `UIColor`, ...
 */
@property (nonatomic, strong) id value;

/**
 *  The line number at which the token appeared in the style file, used for debug and error messages
 */
@property (nonatomic, assign) NSInteger lineNumber;

/**
 *  Factory method for creating tokens with a particular `CASTokenType`
 */
+ (instancetype)tokenOfType:(CASTokenType)type;

/**
 *  Factory method for creating tokens with a particular `CASTokenType` and value
 */
+ (instancetype)tokenOfType:(CASTokenType)type value:(id)value;

/**
 *  Returns a `NSString` representation of a `CASTokenType`
 *  Mainly used for debug output
 *
 *  @param type The `CASTokenType` to convert to a `NSString`
 *
 *  @return a `NSString` representing the passed `CASTokenType`
 */
+ (NSString *)stringForType:(CASTokenType)type;

/**
 *  Returns value of receiver as a string
 */
- (NSString *)stringValue;

/**
 *  Returns whether receiver is a whitespace token or not
 *
 *  @return `YES` if receiver is one of the following types indent, outdent, space, new line.
 */
- (BOOL)isWhitespace;

/**
 *  Returns whether receiver's value is equal to the given value
 *
 *  @param string the value for comparison
 *
 *  @return `YES` if receiver is equal to the given value
 */
- (BOOL)valueIsEqualTo:(id)value;

/**
 *  Returns whether the receiver could be a valid selector token.
 *  However context will determine if it is definitely a selector
 *
 *  @return `YES` if it is possible that the receiver is a selector
 */
- (BOOL)isPossiblySelector;

/**
 *  Returns whether the receiver could be a valid variable token.
 *  However context will determine if it is definitely a variable
 *
 *  @return `YES` if it is possible that the receiver is a variable
 */
- (BOOL)isPossiblyVar;

/**
 *  Returns whether the receiver could be a valid expression token.
 *  However context will determine if it is definitely part of an expression
 *
 *  @return `YES` if it is possible that the receiver is a expression token
 */
- (BOOL)isPossiblyExpression;


/**
 *  Returns whether the receiver could be a valid selector delimiting token.
 *  However context will determine if it is definitely a selector delimiter
 *
 *  @return `YES` if it is possible that the receiver is a selector delimiter
 */
- (BOOL)isPossiblySelectorDelimiter;

@end
