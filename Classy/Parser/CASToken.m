//
//  CASToken.m
//  Classy
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASToken.h"

@interface CASToken ()

@property (nonatomic, assign, readwrite) CASTokenType type;

@end

@implementation CASToken

#pragma mark - debug

+ (NSString *)stringForType:(CASTokenType)type {
    switch (type) {
        case CASTokenTypeUnknown:
            return @"unknown";
        case CASTokenTypeIndent:
            return @"indent";
        case CASTokenTypeOutdent:
            return @"outdent";
        case CASTokenTypeEOS:
            return @"EOS";
        case CASTokenTypeSemiColon:
            return @"semicolon";
        case CASTokenTypeCarat:
            return @"carat";
        case CASTokenTypeNewline:
            return @"newline";
        case CASTokenTypeLeftSquareBrace:
            return @"left square brace";
        case CASTokenTypeRightSquareBrace:
            return @"right square brace";
        case CASTokenTypeLeftCurlyBrace:
            return @"left curly brace";
        case CASTokenTypeRightCurlyBrace:
            return @"right curly brace";
        case CASTokenTypeLeftRoundBrace:
            return @"left round brace";
        case CASTokenTypeRightRoundBrace:
            return @"right round brace";
        case CASTokenTypeColor:
            return @"color";
        case CASTokenTypeString:
            return @"string";
        case CASTokenTypeUnit:
            return @"unit";
        case CASTokenTypeBoolean:
            return @"boolean";
        case CASTokenTypeRef:
            return @"ref";
        case CASTokenTypeOperator:
            return @"operator";
        case CASTokenTypeSpace:
            return @"space";
        case CASTokenTypeSelector:
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

+ (instancetype)tokenOfType:(CASTokenType)type {
    CASToken *token = self.class.new;
    token.type = type;
    return token;
}

+ (instancetype)tokenOfType:(CASTokenType)type value:(id)value {
    CASToken *token = self.class.new;
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
    return self.type == CASTokenTypeIndent
        || self.type == CASTokenTypeOutdent
        || self.type == CASTokenTypeNewline
        || self.type == CASTokenTypeSpace;
}

- (BOOL)valueIsEqualTo:(id)value {
    return [self.value isEqual:value];
}

- (BOOL)isPossiblySelector {
    return self.type == CASTokenTypeRef
        || self.type == CASTokenTypeCarat
        || self.type == CASTokenTypeLeftSquareBrace
        || self.type == CASTokenTypeRightSquareBrace
        || self.type == CASTokenTypeSelector
        || self.type == CASTokenTypeNewline
        || self.type == CASTokenTypeSpace
        || self.type == CASTokenTypeOperator
        || [self valueIsEqualTo:@":"]
        || [self valueIsEqualTo:@","];
}

- (BOOL)isPossiblyVar {
    return self.type == CASTokenTypeIndent
        || self.type == CASTokenTypeSpace
        || self.type == CASTokenTypeRef
        || [self valueIsEqualTo:@"="];
}

- (BOOL)isPossiblyExpression {
    return self.type == CASTokenTypeUnit
        || self.type == CASTokenTypeSpace
        || self.type == CASTokenTypeLeftRoundBrace
        || self.type == CASTokenTypeRightRoundBrace
        || (self.type == CASTokenTypeOperator);
}

- (BOOL)isPossiblySelectorDelimiter{
    return self.type == CASTokenTypeLeftCurlyBrace || self.type == CASTokenTypeIndent;
}

@end
