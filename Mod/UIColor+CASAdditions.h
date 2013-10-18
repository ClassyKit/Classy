//
//  UIColor+CASAdditions.h
//  Classy
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//
//  Slightly modified from https://github.com/soffes/sstoolkit/blob/master/SSToolkit/UIColor%2BSSToolkitAdditions.h
//  Main change namespaced to avoid collisions with other UIColor categories

#import <UIKit/UIKit.h>

@interface UIColor (CASAdditions)

/**
 *  Creates and returns an UIColor object containing a given value.
 *
 *  @param hex The value for the new color. The `#` sign is not required.
 *
 *  @return An UIColor object containing a value.
 *  You can specify hex values in the following formats: `rgb`, `rrggbb`, or `rrggbbaa`.
 *  The default alpha value is `1.0`.
 */
+ (UIColor *)cas_colorWithHex:(NSString *)hex;

/**
 *  Returns the receiver's value as a hex string.
 *
 *  @return The receiver's value as a hex string.
 *  The value will be `nil` if the color is in a color space other than Grayscale or RGB.
 *  The `#` sign is omitted. Alpha will be omitted.
 */
- (NSString *)cas_hexValue;

/**
 *  Returns the receiver's value as a hex string.
 *
 *  @param includeAlpha `YES` if alpha should be included. `NO` if it should not.
 *
 *  @return The receiver's value as a hex string.
 *  The value will be `nil` if the color is in a color space other than Grayscale or RGB.
 *  The `#` sign is omitted. Alpha is included if `includeAlpha` is `YES`.
 */
- (NSString *)cas_hexValueWithAlpha:(BOOL)includeAlpha;

@end
