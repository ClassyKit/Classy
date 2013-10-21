//
//  CASExpressionSolver.h
//  Classy
//
//  Created by Jonas Budelmann on 18/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CASExpressionSolver : NSObject

/**
 *  Takes an array of tokens and reduces any expressions contained within to a numerical value.
 *  Skips tokens which cannot be evaluated in a expression
 *
 *  @return a NSArray of tokens
 */
- (NSArray *)tokensByReducingTokens:(NSArray *)tokens;

@end
