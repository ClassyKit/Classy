//
//  MODToken.m
//  Mod
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODToken.h"

@interface MODToken ()

@property (nonatomic, assign, readwrite) MODTokenType type;

@end

@implementation MODToken

#pragma mark - debug

+ (NSString *)stringForType:(MODTokenType)type {
    switch (type) {
        case MODTokenTypeUnknown:
            return @"unknown";
        case MODTokenTypeIndent:
            return @"indent";
        case MODTokenTypeOutdent:
            return @"outdent";
        case MODTokenTypeEOS:
            return @"EOS";
        case MODTokenTypeSemiColon:
            return @"semicolon";
        case MODTokenTypeCarat:
            return @"carat";
        case MODTokenTypeNewline:
            return @"newline";
        case MODTokenTypeLeftSquareBrace:
            return @"[";
        case MODTokenTypeRightSquareBrace:
            return @"]";
        case MODTokenTypeLeftCurlyBrace:
            return @"{";
        case MODTokenTypeRightCurlyBrace:
            return @"}";
        case MODTokenTypeColor:
            return @"color";
        case MODTokenTypeString:
            return @"string";
        case MODTokenTypeUnit:
            return @"unit";
        case MODTokenTypeBoolean:
            return @"boolean";
        case MODTokenTypeRef:
            return @"ref";
        case MODTokenTypeOperator:
            return @"operator";
        case MODTokenTypeSpace:
            return @"space";
        case MODTokenTypeSelector:
            return @"selector";
    }
}

- (NSString *)description {
    if (self.value) {
        return [NSString stringWithFormat:@"%@ %@", [self.class stringForType:self.type], self.value];
    }
    return [self.class stringForType:self.type];
}

#pragma mark - Factory

+ (instancetype)tokenOfType:(MODTokenType)type {
    MODToken *token = MODToken.new;
    token.type = type;
    return token;
}

#pragma mark - Helpers

- (BOOL)isWhitespace {
    return self.type == MODTokenTypeIndent
        || self.type == MODTokenTypeOutdent
        || self.type == MODTokenTypeNewline
        || self.type == MODTokenTypeSpace;
}

- (BOOL)valueIsEqualTo:(id)value {
    return [self.value isEqual:value];
}

- (BOOL)isPossiblySelector {
    return self.type == MODTokenTypeRef
        || self.type == MODTokenTypeCarat
        || self.type == MODTokenTypeLeftSquareBrace
        || self.type == MODTokenTypeRightSquareBrace
        || self.type == MODTokenTypeSelector
        || self.type == MODTokenTypeNewline
        || self.type == MODTokenTypeSpace
        || self.type == MODTokenTypeOperator
        || [self valueIsEqualTo:@":"]
        || [self valueIsEqualTo:@","];
}

@end
