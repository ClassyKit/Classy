//
//  MODLexer.m
//  Mod
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODLexer.h"
#import "NSRegularExpression+MODAdditions.h"
#import "UIColor+MODAdditions.h"

@interface MODLexer ()

@property (nonatomic, strong) NSMutableString *str;
@property (nonatomic, strong) NSMutableArray *stash;
@property (nonatomic, strong) NSMutableArray *indentStack;
@property (nonatomic, strong) MODToken *previous;
@property (nonatomic, strong) NSDictionary *regexCache;

@end

@implementation MODLexer

- (id)initWithString:(NSString *)str {
    self = [super init];
    if (!self) return nil;

    self.str = [str mutableCopy];
    self.stash = NSMutableArray.new;
    self.indentStack = NSMutableArray.new;

    // replace carriage returns (\r\n | \r) with newlines
    [MODRegex(@"\\r\\n?") mod_replaceMatchesInString:self.str withTemplate:@"\n"];
    
    // trim whitespace & newlines from end of string
    [MODRegex(@"\\s+$") mod_replaceMatchesInString:self.str withTemplate:@"\n"];

    // cache regex's
    self.regexCache = @{
        @(MODTokenTypeSpace)     : @[ MODRegex(@"^([ \\t]+)") ],
        @(MODTokenTypeSemiColon) : @[ MODRegex(@"^;[ \\t]*") ],
        @(MODTokenTypeBrace)     : @[ MODRegex(@"^([{}])") ],
        @(MODTokenTypeColor)     : @[
            MODRegex(@"^#([a-fA-F0-9]{8})[ \\t]*"),
            MODRegex(@"^#([a-fA-F0-9]{6})[ \\t]*"),
            MODRegex(@"^#([a-fA-F0-9]{3})[ \\t]*")
        ],
        @(MODTokenTypeString)    : @[ MODRegex(@"^(\"[^\"]*\"|'[^']*')[ \t]*") ],
    };

    return self;
}


- (MODToken *)peekToken {
    return [self lookahead:1];
}

- (MODToken *)nextToken {
    MODToken *token = self.popToken ?: self.advanceToken;
    self.previous = token;
    return token;
}

#pragma mark - private

- (MODToken *)lookahead:(NSUInteger)n {
    NSInteger fetch = n - self.stash.count;
    while (fetch-- > 0) {
        MODToken *token = self.advanceToken;
        NSAssert(token, @"Could not parse token for string %@", self.str);
        [self.stash addObject:token];
    }
    return self.stash[--n];
}

- (void)skip:(NSUInteger)n {
    [self.str deleteCharactersInRange:NSMakeRange(0, n)];
}

- (MODToken *)advanceToken {
    // TODO optimise
    // this could possibly be faster using simple string scanning (NSScanner), instead of regex
    return self.eos
        ?: self.seperator
        ?: self.brace
        ?: self.color
        ?: self.string
        //?: self.unit
        //?: self.boolean
        //?: self.ident
        ?: self.space;
        //?: self.selector;
}

- (MODToken *)popToken {
    // Return the next stashed token and remove it from stash.
    if (self.stash.count) {
        MODToken *token = self.stash[0];
        [self.stash removeObjectAtIndex:0];
        return token;
    }
    return nil;
}

#pragma mark - tokens

- (MODToken *)eos {
    // EOS | trailing outdents.
    if (self.str.length) return nil;
    if (self.indentStack.count) {
        [self.indentStack removeObjectAtIndex:0];
        return [[MODToken alloc] initWithType:MODTokenTypeOutdent];
    } else {
        return [[MODToken alloc] initWithType:MODTokenTypeEOS];
    }
}

- (MODToken *)string {
    // string enclosed in single or double quotes
    return [self testForTokenType:MODTokenTypeString transformValueBlock:^id(NSString *value) {
        NSString *string = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return [string substringWithRange:NSMakeRange(1, string.length-2)];
    }];
}

- (MODToken *)color {
    //#rrggbbaa | #rrggbb | #rgb
    return [self testForTokenType:MODTokenTypeColor transformValueBlock:^id(NSString *value) {
        return [UIColor mod_colorWithHex:[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }];
}

- (MODToken *)seperator {
    // 1 `;` followed by 0-* ` `
    return [self testForTokenType:MODTokenTypeSemiColon transformValueBlock:nil];
}

- (MODToken *)space {
    // 1-* number of ` `
    return [self testForTokenType:MODTokenTypeSpace transformValueBlock:nil];
}

- (MODToken *)brace {
    // 1 `{` or `}`
    return [self testForTokenType:MODTokenTypeBrace transformValueBlock:^id(NSString *value){
        return value;
    }];
}

#pragma mark - helpers

- (MODToken *)testForTokenType:(MODTokenType)tokenType transformValueBlock:(id(^)(NSString *value))transformValueBlock {
    NSArray *regexes = self.regexCache[@(tokenType)];
    NSAssert(regexes, @"No cached regex for MODTokenType: %d", tokenType);
    for (NSRegularExpression *regex in regexes) {
        NSTextCheckingResult *match = [regex firstMatchInString:self.str options:0 range:NSMakeRange(0, self.str.length)];
        if (match) {
            MODToken *token = MODToken.new;
            token.type = tokenType;
            if (transformValueBlock) {
                token.value = transformValueBlock([self.str substringWithRange:match.range]);
            }
            [self skip:match.range.length];
            return token;
        }
    }
    return nil;
}

@end
