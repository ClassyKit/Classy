//
//  CASStyleProperty.m
//  Classy
//
//  Created by Jonas Budelmann on 25/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASStyleProperty.h"
#import "NSString+CASAdditions.h"
#import "CASExpressionSolver.h"

@interface CASStyleProperty ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSArray *values;

@property (nonatomic, strong, readwrite) CASToken *nameToken;
@property (nonatomic, strong, readwrite) NSArray *valueTokens;

@end

@implementation CASStyleProperty {
    NSMutableArray *_childStyleProperties;
}

@synthesize childStyleProperties = _childStyleProperties;

- (id)initWithNameToken:(CASToken *)nameToken valueTokens:(NSArray *)valueTokens {
    self = [super init];
    if (!self) return nil;

    self.nameToken = nameToken;
    self.valueTokens = valueTokens;

    return self;
}

#pragma mark - properties

- (NSString *)name {
    if (!_name) {
        _name = [self.nameToken.value cas_stringByCamelCasing];
    }
    return _name;
}

- (NSArray *)values {
    if (!_values) {
        NSMutableArray *values = NSMutableArray.new;
        for (CASToken *valueToken in self.valueTokens) {
            if (valueToken.value) {
                [values addObject:valueToken.value];
            }
        }
        _values = values;
    }
    return _values;
}

#pragma mark - helpers

- (id)valueOfTokenType:(CASTokenType)tokenType {
    for (CASToken *token in self.valueTokens) {
        if (token.type == tokenType) return token.value;
    }
    return nil;
}

- (NSArray *)valuesOfTokenType:(CASTokenType)tokenType {
    NSMutableArray *tokens = NSMutableArray.new;
    for (CASToken *token in self.valueTokens) {
        if (token.type == tokenType) {
            [tokens addObject:token.value];
        }
    }
    return tokens;
}

#pragma - value transformation

- (BOOL)transformValuesToCGSize:(CGSize *)size {
    NSArray *unitTokens = [self valuesOfTokenType:CASTokenTypeUnit];
    if (unitTokens.count == 1) {
        CGFloat value = [unitTokens[0] doubleValue];
        *size = CGSizeMake(value, value);
        return YES;
    }
    if (unitTokens.count == 2) {
        CGFloat value1 = [unitTokens[0] doubleValue];
        CGFloat value2 = [unitTokens[1] doubleValue];
        *size = CGSizeMake(value1, value2);
        return YES;
    }
    return NO;
}

- (BOOL)transformValuesToCGPoint:(CGPoint *)point {
    NSArray *unitTokens = [self valuesOfTokenType:CASTokenTypeUnit];
    if (unitTokens.count == 1) {
        CGFloat value = [unitTokens[0] doubleValue];
        *point = CGPointMake(value, value);
        return YES;
    }
    if (unitTokens.count == 2) {
        CGFloat value1 = [unitTokens[0] doubleValue];
        CGFloat value2 = [unitTokens[1] doubleValue];
        *point = CGPointMake(value1, value2);
        return YES;
    }
    return NO;
}

- (BOOL)transformValuesToCGRect:(CGRect *)rect {
    NSArray *unitTokens = [self valuesOfTokenType:CASTokenTypeUnit];
    if (unitTokens.count == 4) {
        *rect = CGRectMake([unitTokens[0] doubleValue], [unitTokens[1] doubleValue], [unitTokens[2] doubleValue], [unitTokens[3] doubleValue]);
        return YES;
    }
    return NO;
}

- (BOOL)transformValuesToUIEdgeInsets:(UIEdgeInsets *)insets {
    NSArray *unitTokens = [self valuesOfTokenType:CASTokenTypeUnit];
    if (unitTokens.count == 1) {
        CGFloat value = [unitTokens[0] doubleValue];
        *insets = UIEdgeInsetsMake(value, value, value, value);
        return YES;
    }
    if (unitTokens.count == 2) {
        CGFloat value1 = [unitTokens[0] doubleValue];
        CGFloat value2 = [unitTokens[1] doubleValue];
        *insets = UIEdgeInsetsMake(value1, value2, value1, value2);
        return YES;
    }
    if (unitTokens.count == 4) {
        *insets = UIEdgeInsetsMake([unitTokens[0] doubleValue], [unitTokens[1] doubleValue], [unitTokens[2] doubleValue], [unitTokens[3] doubleValue]);
        return YES;
    }
    return NO;
}

- (BOOL)transformValuesToUIOffset:(UIOffset *)offset {
    NSArray *unitTokens = [self valuesOfTokenType:CASTokenTypeUnit];
    if (unitTokens.count == 1) {
        CGFloat value = [unitTokens[0] doubleValue];
        *offset = UIOffsetMake(value, value);
        return YES;
    }
    if (unitTokens.count == 2) {
        CGFloat value1 = [unitTokens[0] doubleValue];
        CGFloat value2 = [unitTokens[1] doubleValue];
        *offset = UIOffsetMake(value1, value2);
        return YES;
    }
    return NO;
}

- (BOOL)transformValuesToUIColor:(UIColor **)color {
    UIColor *colorValue = [self valueOfTokenType:CASTokenTypeColor];
    if (colorValue) {
        *color = colorValue;
        return YES;
    }

    NSString *value = [self valueOfTokenType:CASTokenTypeRef]
        ?: [self valueOfTokenType:CASTokenTypeSelector]
        ?: [self valueOfTokenType:CASTokenTypeString];

    value = [value cas_stringByCamelCasing];
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@Color", value]);
    if (selector && [UIColor.class respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        *color = [UIColor.class performSelector:selector];
#pragma clang diagnostic pop
        return YES;
    }

    return NO;
}

- (BOOL)transformValuesToNSString:(NSString **)string {
    NSString *value = [self valueOfTokenType:CASTokenTypeString]
        ?: [self valueOfTokenType:CASTokenTypeRef]
        ?: [self valueOfTokenType:CASTokenTypeSelector];
    if (value) {
        *string = value;
        return YES;
    }

    return NO;
}

- (BOOL)transformValuesToUIImage:(UIImage **)image {
    UIEdgeInsets insets;
    BOOL hasInsets = [self transformValuesToUIEdgeInsets:&insets];

    NSString *imageName = [self valueOfTokenType:CASTokenTypeString] ?: [self valueOfTokenType:CASTokenTypeRef];
    UIImage *imageValue = [UIImage imageNamed:imageName];
    if (hasInsets) {
        imageValue = [imageValue resizableImageWithCapInsets:insets];
    }
    if (imageValue) {
        *image = imageValue;
        return YES;
    }
    return NO;
}

- (BOOL)transformValuesToUIFont:(UIFont **)font {
    NSNumber *fontSize = [self valueOfTokenType:CASTokenTypeUnit];
    NSString *fontName = [self valueOfTokenType:CASTokenTypeString]
        ?: [self valueOfTokenType:CASTokenTypeRef]
        ?: [self valueOfTokenType:CASTokenTypeSelector];

    if (!fontSize && !fontName.length) {
        return NO;
    }

    CGFloat fontSizeValue = [fontSize floatValue] ?: [UIFont systemFontSize];
    if (fontName) {
        *font = [UIFont fontWithName:fontName size:fontSizeValue];
    } else {
        *font = [UIFont systemFontOfSize:fontSizeValue];
    }
    return YES;
}

- (void)resolveExpressions {
    BOOL hasOperator = NO;
    for (CASToken *token in self.valueTokens) {
        if (token.type == CASTokenTypeOperator && ![token valueIsEqualTo:@","]) {
            hasOperator = YES;
            break;
        }
    }

    if (!hasOperator) return;

    CASExpressionSolver *solver = CASExpressionSolver.new;
    self.valueTokens = [solver tokensByReducingTokens:self.valueTokens];
    self.values = nil;
}

- (void)addChildStyleProperty:(CASStyleProperty *)styleProperty {
    if (!_childStyleProperties) {
        _childStyleProperties = NSMutableArray.new;
    }
    [_childStyleProperties addObject:styleProperty];
}

@end
