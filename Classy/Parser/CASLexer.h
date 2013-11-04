//
//  CASLexer.h
//  Classy
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CASToken.h"

extern NSString * const CASParseErrorDomain;
extern NSInteger const CASParseErrorInvalidToken;
extern NSInteger const CASParseErrorInvalidIndentation;
extern NSString * const CASParseFailingLineNumberErrorKey;
extern NSString * const CASParseFailingStringErrorKey;

@interface CASLexer : NSObject

/**
 *  The error, if any, that occurred during tokenisation
 */
@property (nonatomic, strong, readonly) NSError *error;

/**
 *  The remaining length of string to tokenise
 */
@property (nonatomic, assign, readonly) NSInteger length;

/**
 *  Create new `CASLexer` with a `NSString` to Tokenize
 */
- (id)initWithString:(NSString *)str;

/**
 *  Create a error and attach current string and line number to userInfo
 */
- (NSError *)errorWithDescription:(NSString *)description reason:(NSString *)reason code:(NSUInteger)code;

/**
 *  Token from stash or by advancing.
 *
 *  @return a `CASToken` which will remain or be added to the stash
 */
- (CASToken *)peekToken;

/**
 *  Token from stash or by advancing.
 *
 *  @return a `CASToken` which if coming from stash will be removed
 */
- (CASToken *)nextToken;

/**
 *  lookahead advances stash if needed
 *  then returns the token `count` from top of stash
 *
 *  @param count number of tokens to lookahead, minimum=1
 *
 *  @return The token corresponding to the number of lookaheads
 */
- (CASToken *)lookaheadByCount:(NSUInteger)count;

@end
