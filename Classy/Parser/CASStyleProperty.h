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
 *  child style properties
 */
@property (nonatomic, strong, readonly) NSArray *childStyleProperties;

/**
 *  Provides support for properties that have extra arguments such as
 *  - setTitle:forState:
 */
@property (nonatomic, strong) NSDictionary *arguments;

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
 *  Returns all consecutive valueTokens of a specific token type
 *  Will ignore whitespace and commas
 *
 *  @param tokenType `CASTokenType` sought
 *
 *  @return a `CASToken`
 */
- (NSArray *)consecutiveValuesOfTokenType:(CASTokenType)tokenType;

/**
 *  Attempts to extract a CGSize from the valueTokens
 *
 *  @param size CGSize pointer
 *
 *  @return whether the extraction succeeded
 */
- (BOOL)transformValuesToCGSize:(CGSize *)size;

/**
 *  Attempts to extract a CGPoint from the valueTokens
 *
 *  @param size CGPoint pointer
 *
 *  @return whether the extraction succeeded
 */
- (BOOL)transformValuesToCGPoint:(CGPoint *)point;

/**
 *  Attempts to extract a CGRect from the valueTokens
 *
 *  @param size CGRect pointer
 *
 *  @return whether the extraction succeeded
 */
- (BOOL)transformValuesToCGRect:(CGRect *)rect;

/**
 *  Attempts to extract a UIOffset from the valueTokens
 *
 *  @param offset UIOffset pointer
 *
 *  @return whether the extraction succeeded
 */
- (BOOL)transformValuesToUIOffset:(UIOffset *)offset;

/**
 *  Attempts to extract a UIEdgeInsets from the valueTokens
 *
 *  @param size UIEdgeInsets pointer
 *
 *  @return whether the extraction succeeded
 */
- (BOOL)transformValuesToUIEdgeInsets:(UIEdgeInsets *)insets;

/**
 *  Attempts to extract a UIColor from the valueTokens
 *
 *  @param color UIColor pointer
 *
 *  @return whether the extraction succeeded
 */
- (BOOL)transformValuesToUIColor:(UIColor **)color;

/**
 *  Attempts to extract a UIImage from the valueTokens
 *
 *  @param image UIImage pointer
 *
 *  @return whether the extraction succeeded
 */
- (BOOL)transformValuesToUIImage:(UIImage **)image;

/**
 *  Attempts to extract a NSString from the valueTokens
 *
 *  @param string NSString pointer
 *
 *  @return whether the extraction succeeded
 */
- (BOOL)transformValuesToNSString:(NSString **)string;

/**
 *  Attempts to extract a UIFont from the valueTokens
 *
 *  @param font UIFont pointer
 *
 *  @return whether the extraction succeeded
 */
- (BOOL)transformValuesToUIFont:(UIFont **)font;

/**
 *  Replace any detected expressions/equations with a numerical value
 */
- (void)resolveExpressions;

/**
 *  adds nested CASStyleProperty to the receiver
 */
- (void)addChildStyleProperty:(CASStyleProperty *)styleProperty;

@end
