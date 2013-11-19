//
//  UIColor+CASAdditions.m
//  Classy
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "UIColor+CASAdditions.h"

@interface NSString (CASPrivateAdditions)
- (NSUInteger)cas_hexValue;
@end

@implementation NSString (CASPrivateAdditions)
- (NSUInteger)cas_hexValue {
    NSUInteger result = 0;
    sscanf([self UTF8String], "%x", &result);
    return result;
}
@end

@implementation UIColor (CASAdditions)

+ (UIColor *)cas_colorWithRGB:(NSString *)rgb {
    // Invalid don't start with rgb(
    if(![rgb hasPrefix:@"rgb("] && ![rgb hasPrefix:@"rgba("]) {
        return nil;
    }
    
    NSString *colorString = [[rgb stringByReplacingOccurrencesOfString:([rgb hasPrefix:@"rgba("] ? @"rgba(" : @"rgb(") withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSArray *colors = [colorString componentsSeparatedByString:@","];
    
    CGFloat alpha = 1.f;
    
    // invalid if you don't have 3 colors
    if(colors.count < 3) {
        return nil;
    } else if(colors.count == 4){
        alpha = [colors[3] floatValue];
    }
    
    return [UIColor colorWithRed:[colors[0] floatValue]/255.f green:[colors[1] floatValue]/255.f blue:[colors[2] floatValue]/255.f alpha:alpha];
}

+ (UIColor *)cas_colorWithHex:(NSString *)hex {
    // Remove `#` and `0x`
    if ([hex hasPrefix:@"#"]) {
        hex = [hex substringFromIndex:1];
    } else if ([hex hasPrefix:@"0x"]) {
        hex = [hex substringFromIndex:2];
    }

    // Invalid if not 3, 6, or 8 characters
    NSUInteger length = [hex length];
    if (length != 3 && length != 6 && length != 8) {
        return nil;
    }

    // Make the string 8 characters long for easier parsing
    if (length == 3) {
        NSString *r = [hex substringWithRange:NSMakeRange(0, 1)];
        NSString *g = [hex substringWithRange:NSMakeRange(1, 1)];
        NSString *b = [hex substringWithRange:NSMakeRange(2, 1)];
        hex = [NSString stringWithFormat:@"%@%@%@%@%@%@ff",
               r, r, g, g, b, b];
    } else if (length == 6) {
        hex = [hex stringByAppendingString:@"ff"];
    }

    CGFloat red = [[hex substringWithRange:NSMakeRange(0, 2)] cas_hexValue] / 255.0f;
    CGFloat green = [[hex substringWithRange:NSMakeRange(2, 2)] cas_hexValue] / 255.0f;
    CGFloat blue = [[hex substringWithRange:NSMakeRange(4, 2)] cas_hexValue] / 255.0f;
    CGFloat alpha = [[hex substringWithRange:NSMakeRange(6, 2)] cas_hexValue] / 255.0f;

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (NSString *)cas_hexValue {
    return [self cas_hexValueWithAlpha:NO];
}

- (NSString *)cas_hexValueWithAlpha:(BOOL)includeAlpha {
    CGColorRef color = self.CGColor;
    size_t count = CGColorGetNumberOfComponents(color);
    const CGFloat *components = CGColorGetComponents(color);

    static NSString *stringFormat = @"%02x%02x%02x";

    NSString *hex = nil;

    // Grayscale
    if (count == 2) {
        NSUInteger white = (NSUInteger)(components[0] * 255.0f);
        hex = [NSString stringWithFormat:stringFormat, white, white, white];
    }

    // RGB
    else if (count == 4) {
        hex = [NSString stringWithFormat:stringFormat, (NSUInteger)(components[0] * 255.0f),
               (NSUInteger)(components[1] * 255.0f), (NSUInteger)(components[2] * 255.0f)];
    }
    
    // Add alpha
    if (hex && includeAlpha) {
        hex = [hex stringByAppendingFormat:@"%02x", (NSUInteger)(CGColorGetAlpha(self.CGColor) * 255.0f)];
    }
    
    // Unsupported color space
    return hex;
}

@end
