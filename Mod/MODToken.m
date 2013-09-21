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

+ (NSString *)stringForType:(MODTokenType)type {
    switch (type) {
        case MODTokenTypeIndent:
            return @"indent";
        case MODTokenTypeOutdent:
            return @"outdent";
        case MODTokenTypeEOS:
            return @"EOS";
        case MODTokenTypeSemiColon:
            return @"semicolon";
        case MODTokenTypeNewline:
            return @"newline";
        case MODTokenTypeBrace:
            return @"brace";
        case MODTokenTypeColor:
            return @"color";
        case MODTokenTypeString:
            return @"string";
        case MODTokenTypeUnit:
            return @"unit";
        case MODTokenTypeBoolean:
            return @"boolean";
        case MODTokenTypeRef:
            return @"ident";
        case MODTokenTypeSpace:
            return @"space";
        case MODTokenTypeSelector:
            return @"selector";
    }
}

+ (instancetype)tokenOfType:(MODTokenType)type {
    MODToken *token = MODToken.new;
    token.type = type;
    return token;
}

- (NSString *)description {
    if (self.value) {
        return [NSString stringWithFormat:@"%@:%@", [self.class stringForType:self.type], self.value];
    }
    return [self.class stringForType:self.type];
}

@end
