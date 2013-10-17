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
        case MODTokenTypeLeftRoundBrace:
            return @"(";
        case MODTokenTypeRightRoundBrace:
            return @")";
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

+ (instancetype)tokenOfType:(MODTokenType)type value:(id)value {
    MODToken *token = MODToken.new;
    token.type = type;
    token.value = value;
    return token;
}

#pragma mark - Helpers

- (NSString *)stringValue {
    if ([self.value isKindOfClass:NSString.class]) {
        return self.value;
    }
    return [self.value stringValue];
}

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

- (BOOL)isPossiblyVar {
    return self.type == MODTokenTypeIndent
        || self.type == MODTokenTypeSpace
        || self.type == MODTokenTypeRef
        || [self valueIsEqualTo:@"="];
}

- (BOOL)isPossiblyExpression {
    return self.type == MODTokenTypeUnit
        || self.type == MODTokenTypeSpace
        || self.type == MODTokenTypeLeftRoundBrace
        || self.type == MODTokenTypeRightRoundBrace
        || (self.type == MODTokenTypeOperator);
}

@end
