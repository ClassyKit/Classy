//
//  MODLexer.h
//  Mod
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MODToken.h"

extern NSString * const MODParseErrorDomain;
extern NSInteger const MODParseErrorInvalidToken;
extern NSInteger const MODParseErrorInvalidIndentation;
extern NSString * const MODParseFailingLineNumberErrorKey;
extern NSString * const MODParseFailingStringErrorKey;

@interface MODLexer : NSObject

/**
 *  The error, if any, that occurred during tokenisation
 */
@property (nonatomic, strong, readonly) NSError *error;

/**
 *  Create new `MODLexer` with a `NSString` to Tokenize
 */
- (id)initWithString:(NSString *)str;

/**
 *  Create a error and attach current string and line number to userInfo
 */
- (NSError *)errorWithDescription:(NSString *)description reason:(NSString *)reason code:(NSUInteger)code;

/**
 *  Token from stash or by advancing.
 *
 *  @return a `MODToken` which will remain or be added to the stash
 */
- (MODToken *)peekToken;

/**
 *  Token from stash or by advancing.
 *
 *  @return a `MODToken` which if coming from stash will be removed
 */
- (MODToken *)nextToken;

/**
 *  lookahead advances stash if needed
 *  then returns the token `count` from top of stash
 *
 *  @param count number of tokens to lookahead, minimum=1
 *
 *  @return The token corresponding to the number of lookaheads
 */
- (MODToken *)lookaheadByCount:(NSUInteger)count;

@end
