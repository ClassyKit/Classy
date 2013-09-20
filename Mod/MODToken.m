//
//  MODToken.m
//  Mod
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODToken.h"

@implementation MODToken

+ (NSString *)stringForType:(MODTokenType)type {
    switch (type) {
        case MODTokenTypeEOS:
            return @"EOS";
        case MODTokenTypeNewline:
            return @"newline";
        case MODTokenTypeSemiColon:
            return @"semicolon";
        case MODTokenTypeColon:
            return @"colon";
        case MODTokenTypeIndent:
            return @"ident";
        case MODTokenTypeOutdent:
            return @"outdent";
        case MODTokenTypeSpace:
            return @"space";
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
    }
}

- (id)initWithType:(MODTokenType)type value:(id)value {
    self = [super init];
    if (!self) return nil;

    self.type = type;
    self.value = value;

    return self;
}

- (id)initWithType:(MODTokenType)type {
    self = [super init];
    if (!self) return nil;

    self.type = type;

    return self;
}

- (NSString *)description {
    if (self.value) {
        return [NSString stringWithFormat:@"%@:%@", [self.class stringForType:self.type], self.value];
    }
    return [self.class stringForType:self.type];
}

@end
