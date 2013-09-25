//
//  MODLexer.h
//  Mod
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MODToken.h"

@interface MODLexer : NSObject

/**
 *  Create new `MODLexer` with a `NSString` to Tokenize
 */
- (id)initWithString:(NSString *)str;


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
