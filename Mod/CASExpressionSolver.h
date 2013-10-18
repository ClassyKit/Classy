//
//  CASExpressionSolver.h
//  Classy
//
//  Created by Jonas Budelmann on 18/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CASExpressionSolver : NSObject

@property (nonatomic, strong) NSMutableArray *tokens;

- (NSArray *)reduceTokens;

@end
