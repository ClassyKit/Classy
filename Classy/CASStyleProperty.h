//
//  MODStyleProperty.h
//  Mod
//
//  Created by Jonas Budelmann on 25/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CASToken.h"

@interface CASStyleProperty : NSObject

/**
 *  Name of the receiver
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  Raw values of the receiver
 */
@property (nonatomic, strong, readonly) NSArray *values;

/**
 *  Name token of the receiver
 */
@property (nonatomic, strong, readonly) CASToken *nameToken;

/**
 *  value tokens of the receiver
 */
@property (nonatomic, strong, readonly) NSArray *valueTokens;

/**
 *  NSInvocation to apply to appropriate view
 */
@property (nonatomic, strong) NSInvocation *invocation;

- (id)initWithNameToken:(CASToken *)nameToken valueTokens:(NSArray *)valueTokens;

- (id)valueOfTokenType:(CASTokenType)tokenType;
- (NSArray *)valuesOfTokenType:(CASTokenType)tokenType;

- (BOOL)transformValuesToCGSize:(CGSize *)size;
- (BOOL)transformValuesToUIEdgeInsets:(UIEdgeInsets *)insets;

- (void)resolveExpressions;

@end
