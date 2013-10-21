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

/**
 *  Creates property with raw data in the form of CATokens
 */
- (id)initWithNameToken:(CASToken *)nameToken valueTokens:(NSArray *)valueTokens;

/**
 *  Returns first valueToken of a specific token type
 *
 *  @param tokenType `CASTokenType` sought
 *
 *  @return a `CASToken`
 */
- (id)valueOfTokenType:(CASTokenType)tokenType;

/**
 *  Returns all valueTokens of a specific token type
 *
 *  @param tokenType `CASTokenType` sought
 *
 *  @return a `CASToken`
 */
- (NSArray *)valuesOfTokenType:(CASTokenType)tokenType;

/**
 *  Attempts to extract a CGSize from the valueTokens
 *
 *  @param size CGSize pointer
 *
 *  @return whether the extraction succeeded
 */
- (BOOL)transformValuesToCGSize:(CGSize *)size;

/**
 *  Attempts to extract a UIEdgeInsets from the valueTokens
 *
 *  @param size UIEdgeInsets pointer
 *
 *  @return whether the extraction succeeded
 */
- (BOOL)transformValuesToUIEdgeInsets:(UIEdgeInsets *)insets;

/**
 *  Replace any detected expressions/equations with a numerical value
 */
- (void)resolveExpressions;

@end
