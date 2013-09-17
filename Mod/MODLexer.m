//
//  MODLexer.m
//  Mod
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODLexer.h"
#import "NSRegularExpression+MODAdditions.h"

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
        @(MODTokenTypeSpace) : MODRegex(@"^([ \\t]+)"),
        @(MODTokenTypeSemiColon) : MODRegex(@"^;[ \\t]*"),
        @(MODTokenTypeBrace) : MODRegex(@"^([{}])"),
    };

    return self;
}


- (MODToken *)peek {
    return [self lookahead:1];
}

- (MODToken *)next {
    MODToken *token = self.stashed ?: self.advance;
    self.previous = token;
    return token;
}

#pragma mark - private

- (MODToken *)lookahead:(NSUInteger)n {
    NSInteger fetch = n - self.stash.count;
    while (fetch-- > 0) {
        [self.stash addObject:self.advance];
    }
    return self.stash[--n];
}

- (void)skip:(NSUInteger)n {
    [self.str deleteCharactersInRange:NSMakeRange(0, n)];
}

- (MODToken *)advance {
    return self.eos
        ?: self.seperator
        ?: self.space
        ?: self.brace;
}

- (MODToken *)stashed {
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

- (MODToken *)testForTokenType:(MODTokenType)tokenType includeValue:(BOOL)includeValue {
    NSRegularExpression *regex = self.regexCache[@(tokenType)];
    NSAssert(regex, @"No cached regex for MODTokenType: %d", tokenType);
    NSTextCheckingResult *match = [regex firstMatchInString:self.str options:0 range:NSMakeRange(0, self.str.length)];
    if (match) {
        MODToken *token = MODToken.new;
        token.type = tokenType;
        if (includeValue) {
            token.value = [self.str substringWithRange:match.range];
        }
        [self skip:match.range.length];
        return token;
    }
    return nil;
}

- (MODToken *)seperator {
    // 1 `;` followed by 0-* ` `
    return [self testForTokenType:MODTokenTypeSemiColon includeValue:NO];
}

- (MODToken *)space {
    // 1-* number of ` `
    return [self testForTokenType:MODTokenTypeSpace includeValue:NO];
}

- (MODToken *)brace {
    // 1 `{` or `}`
    return [self testForTokenType:MODTokenTypeBrace includeValue:YES];
}

@end
