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

- (id)initWithString:(NSString *)str;


/**
 *  Token from stash or by advancing.
 *
 *  @return Token returned will be in in stash
 */
- (MODToken *)peekToken;

/**
 *  Token from stash or by advancing.
 *
 *  @return Token returned will not to be in stash
 */
- (MODToken *)nextToken;


- (MODToken *)lookahead:(NSUInteger)n;

@end
