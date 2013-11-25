//
//  CASLexer.m
//  Classy
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASLexer.h"
#import "NSRegularExpression+CASAdditions.h"
#import "NSString+CASAdditions.h"
#import "UIColor+CASAdditions.h"
#import "CASUnitToken.h"

NSString * const CASParseErrorDomain = @"CASParseErrorDomain";
NSInteger const CASParseErrorInvalidToken = 1;
NSInteger const CASParseErrorInvalidIndentation = 2;
NSString * const CASParseFailingLineNumberErrorKey = @"CASParseFailingLineNumberErrorKey";
NSString * const CASParseFailingStringErrorKey = @"CASParseFailingStringErrorKey";

@interface CASLexer ()

@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, strong) NSMutableString *str;
@property (nonatomic, strong) NSMutableArray *stash;
@property (nonatomic, strong) NSMutableArray *indentStack;
@property (nonatomic, strong) CASToken *previousToken;
@property (nonatomic, strong) NSDictionary *regexCache;
@property (nonatomic, strong) NSRegularExpression *indentRegex;
@property (nonatomic, assign) NSInteger lineNumber;

@end

@implementation CASLexer

- (id)initWithString:(NSString *)str {
    self = [super init];
    if (!self) return nil;

    self.str = [str mutableCopy];
    self.stash = NSMutableArray.new;
    self.indentStack = NSMutableArray.new;
    self.lineNumber = 1;

    // replace carriage returns (\r\n | \r) with newlines
    [CASRegex(@"\\r\\n?") cas_replaceMatchesInString:self.str withTemplate:@"\n"];
    
    // trim whitespace & newlines from end of string
    [CASRegex(@"\\s+$") cas_replaceMatchesInString:self.str withTemplate:@"\n"];

    NSString *units = [@[@"pt", @"px", @"%"] componentsJoinedByString:@"|"];

    // cache regex's
    self.regexCache = @{

        // 1 of `;` followed by 0-* of whitespace
        @(CASTokenTypeSemiColon) : @[ CASRegex(@"^;[ \\t]*") ],

        // 1 of `^` followed by 0-* of whitespace
        @(CASTokenTypeCarat)     : @[ CASRegex(@"^\\^[ \\t]*") ],

        // new line followed by tabs or spaces
        @(CASTokenTypeIndent)    : @[ CASRegex(@"^\\n([\\t]*)"),
                                      CASRegex(@"^\\n([ ]*)") ],

        // #rrggbbaa | #rrggbb | #rgb
        @(CASTokenTypeColor)     : @[ CASRegex(@"^#([a-fA-F0-9]{8})[ \\t]*"),
                                      CASRegex(@"^#([a-fA-F0-9]{6})[ \\t]*"),
                                      CASRegex(@"^#([a-fA-F0-9]{3})[ \\t]*") ],

        // string enclosed in single or double quotes
        @(CASTokenTypeString)    : @[ CASRegex(@"^(\"[^\"]*\"|'[^']*')[ \\t]*") ],

        // decimal/integer number with optional (px, pt) suffix
        @(CASTokenTypeUnit)      : @[ CASRegex(@"^(-)?(\\d+\\.\\d+|\\d+|\\.\\d+)(%@)?[ \\t]*", units) ],

        // true | false | YES | NO
        @(CASTokenTypeBoolean)   : @[ CASRegex(@"^(true|false|YES|NO)\\b([ \\t]*)") ],

        // optional `@` | `-` then at least one `_a-zA-Z$` following by any alphanumeric char or `-` or `$`
        @(CASTokenTypeRef)       : @[ CASRegex(@"^(@)?(-*[_a-zA-Z$][-\\w\\d$]*)") ],

        // tests if string looks like math operation
        @(CASTokenTypeOperator)  : @[ CASRegex(@"^([.]{2,3}|&&|\\|\\||[!<>=?:]=|\\*\\*|[-+*\\/%%]=?|[,=?:!~<>&\\[\\]])([ \\t]*)") ],

        // 1-* of whitespace
        @(CASTokenTypeSpace)     : @[ CASRegex(@"^([ \\t]+)") ],

        // any character except `\n` | `{` | `,` | whitespace
        @(CASTokenTypeSelector)  : @[ CASRegex(@"^.*?(?=\\/\\/|[ \\t,\\n{])") ]
    };

    return self;
}

- (NSInteger)length {
    return self.str.length;
}

- (CASToken *)peekToken {
    return [self lookaheadByCount:1];
}

- (CASToken *)nextToken {
    CASToken *token = self.popToken;
    if (!token) {
        token = self.advanceToken;
        [self attachDebugInfoForToken:token];
    }
    self.previousToken = token;
    return token;
}

- (CASToken *)lookaheadByCount:(NSUInteger)count {
    NSAssert(count > 0, @"Invalid lookahead. Count `%d` must be >= 1", count);
    NSInteger fetch = count - self.stash.count;
    while (fetch > 0) {
        CASToken *token = self.advanceToken;
        [self attachDebugInfoForToken:token];
        [self.stash addObject:token];
        fetch = count - self.stash.count;
    }
    return self.stash[count-1];
}

- (void)attachDebugInfoForToken:(CASToken *)token {
    switch (token.type) {
        case CASTokenTypeNewline:
        case CASTokenTypeIndent:
            ++self.lineNumber;
            break;
        case CASTokenTypeOutdent:
            if (CASTokenTypeOutdent != self.previousToken.type) ++self.lineNumber;
            break;
        default:
            break;
    }
    token.lineNumber = self.lineNumber;
}

- (NSError *)errorWithDescription:(NSString *)description reason:(NSString *)reason code:(NSUInteger)code {
    NSInteger length = MIN(self.str.length, 25);
    NSString *format = length != self.str.length ? @"\"%@ ...\"" : @"\"%@\"";
    NSString *string = [NSString stringWithFormat:format, [self.str substringToIndex:length]];
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: description,
        NSLocalizedFailureReasonErrorKey: reason,
        CASParseFailingLineNumberErrorKey: @(self.lineNumber),
        CASParseFailingStringErrorKey: string
    };
    return [NSError errorWithDomain:CASParseErrorDomain code:code userInfo:userInfo];
}

#pragma mark - private

- (void)skip:(NSUInteger)n {
    [self.str deleteCharactersInRange:NSMakeRange(0, n)];
}

- (CASToken *)advanceToken {
    // TODO optimise
    // this could possibly be faster using simple string scanning (NSScanner), instead of regex
    // however all these regexs are anchored to start of string so should be fairly quick
    CASToken *token = self.eos
        ?: self.seperator
        ?: self.carat
        ?: self.comment
        ?: self.newline
        ?: self.squareBrace
        ?: self.curlyBrace
        ?: self.roundBrace
        ?: self.color
        ?: self.string
        ?: self.unit
        ?: self.boolean
        ?: self.ref
        ?: self.operation
        ?: self.space
        ?: self.selector;

    if (!token) {
        self.error = [self errorWithDescription:@"Invalid style string"
                                         reason:@"Could not determine token"
                                           code:CASParseErrorInvalidToken];
        return nil;
    }

    return token;
}

- (CASToken *)popToken {
    // Return the next stashed token and remove it from stash.
    if (self.stash.count) {
        CASToken *token = self.stash[0];
        [self.stash removeObjectAtIndex:0];
        return token;
    }
    return nil;
}

#pragma mark - tokens

- (CASToken *)eos {
    // EOS | trailing outdents.
    if (self.str.length) return nil;
    if (self.indentStack.count) {
        [self.indentStack removeObjectAtIndex:0];
        return [CASToken tokenOfType:CASTokenTypeOutdent];
    } else {
        return [CASToken tokenOfType:CASTokenTypeEOS];
    }
}

- (CASToken *)seperator {
    return [self testForTokenType:CASTokenTypeSemiColon transformValueBlock:nil];
}

- (CASToken *)carat {
    return [self testForTokenType:CASTokenTypeCarat transformValueBlock:^id(NSString *value, NSTextCheckingResult *match) {
        return value;
    }];
}

- (CASToken *)comment {
    // Single line
    if ([self.str hasPrefix:@"//"]) {
        NSInteger nextLine = [self.str rangeOfString:@"\n"].location;
        if (nextLine == NSNotFound) {
            nextLine = self.str.length;
        }
        [self skip:nextLine];
        return self.advanceToken;
    }

    // Multi-line
    if ([self.str hasPrefix:@"/*"]) {
        NSInteger closeComment = [self.str rangeOfString:@"*/"].location;
        if (closeComment == NSNotFound) {
            closeComment = self.str.length;
        } else {
            closeComment += 2;
        }
        NSInteger lines = [[self.str substringWithRange:NSMakeRange(0, closeComment)] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]].count;

        self.lineNumber += lines - 1;
        [self skip:closeComment];
        return self.advanceToken;
    }
    
    return nil;
}

- (CASToken *)newline {
    // we have established the indentation regexp
    NSTextCheckingResult *match;
    if (self.indentRegex){
        match = [self.indentRegex firstMatchInString:self.str options:0 range:NSMakeRange(0, self.str.length)];
    } else {
        // figure out if we are using tabs or spaces
        for (NSRegularExpression *regex in self.regexCache[@(CASTokenTypeIndent)]) {
            match = [regex firstMatchInString:self.str options:0 range:NSMakeRange(0, self.str.length)];
            if (match && [match rangeAtIndex:1].length) {
                self.indentRegex = regex;
                break;
            }
        }
    }

    if (!match) return nil;

    [self skip:match.range.length];

    if ([self.str hasPrefix:@" "] || [self.str hasPrefix:@"\t"]) {
        ++self.lineNumber;
        self.error = [self errorWithDescription:@"Invalid indentation"
                                         reason:@"You can use tabs or spaces to indent, but not both."
                                           code:CASParseErrorInvalidIndentation];
        return nil;
    }

    // Blank line
    if ([self.str hasPrefix:@"\n"]) {
        ++self.lineNumber;
        return self.advanceToken;
    }

    NSInteger indents = [match rangeAtIndex:1].length;
    if (self.indentStack.count && indents < [self.indentStack[0] integerValue]) {
        while (self.indentStack.count && [self.indentStack[0] integerValue] > indents) {
            [self.stash addObject:[CASToken tokenOfType:CASTokenTypeOutdent]];
            [self.indentStack removeObjectAtIndex:0];
        }
        return [self advanceToken];
    } else if (indents && indents != (self.indentStack.count ? [self.indentStack[0] integerValue] : 0)) {
        [self.indentStack insertObject:@(indents) atIndex:0];
        return [CASToken tokenOfType:CASTokenTypeIndent];
    } else {
        return [CASToken tokenOfType:CASTokenTypeNewline];
    }

    return self.advanceToken;
}

- (CASToken *)squareBrace {
    if ([self.str hasPrefix:@"["]) {
        [self skip:1];
        return [CASToken tokenOfType:CASTokenTypeLeftSquareBrace value:@"["];
    }
    if ([self.str hasPrefix:@"]"]) {
        [self skip:1];
        return [CASToken tokenOfType:CASTokenTypeRightSquareBrace value:@"]"];
    }
    return nil;
}

- (CASToken *)curlyBrace {
    if ([self.str hasPrefix:@"{"]) {
        [self skip:1];
        return [CASToken tokenOfType:CASTokenTypeLeftCurlyBrace value:@"{"];
    }
    if ([self.str hasPrefix:@"}"]) {
        [self skip:1];
        return [CASToken tokenOfType:CASTokenTypeRightCurlyBrace value:@"}"];
    }
    return nil;
}

- (CASToken *)roundBrace {
    if ([self.str hasPrefix:@"("]) {
        [self skip:1];
        return [CASToken tokenOfType:CASTokenTypeLeftRoundBrace value:@"("];
    }
    if ([self.str hasPrefix:@")"]) {
        [self skip:1];
        return [CASToken tokenOfType:CASTokenTypeRightRoundBrace value:@")"];
    }
    return nil;
}

- (CASToken *)color {
    return [self testForTokenType:CASTokenTypeColor transformValueBlock:^id(NSString *value, NSTextCheckingResult *match) {
        return [UIColor cas_colorWithHex:[value cas_stringByTrimmingWhitespace]];
    }];
}

- (CASToken *)string {
    return [self testForTokenType:CASTokenTypeString transformValueBlock:^id(NSString *value, NSTextCheckingResult *match) {
        NSString *string = [value cas_stringByTrimmingWhitespace];
        return [string substringWithRange:NSMakeRange(1, string.length-2)];
    }];
}

- (CASToken *)unit {
    __block NSString *suffix;
    __block NSString *rawValue;
    CASUnitToken *unitToken = (id)[self testForTokenType:CASTokenTypeUnit tokenClass:CASUnitToken.class transformValueBlock:^id(NSString *value, NSTextCheckingResult *match){
        NSRange suffixRange = [match rangeAtIndex:match.numberOfRanges-1];
        if (suffixRange.location != NSNotFound) {
            suffix = [value substringWithRange:suffixRange];
        }

        NSRange valueRange = [match rangeAtIndex:0];
        if (valueRange.location != NSNotFound) {
            rawValue = [value substringWithRange:valueRange];
        }
        return @([rawValue doubleValue]);
    }];

    if (unitToken) {
        unitToken.suffix = suffix;
        unitToken.rawValue = rawValue;
    }

    return unitToken;
}

- (CASToken *)boolean {
    return [self testForTokenType:CASTokenTypeBoolean transformValueBlock:^id(NSString *value, NSTextCheckingResult *match) {
        return @([value hasPrefix:@"true"] || [value hasPrefix:@"YES"]);
    }];
}

- (CASToken *)ref {
    return [self testForTokenType:CASTokenTypeRef transformValueBlock:^id(NSString *value, NSTextCheckingResult *match) {
        return value;
    }];
}

- (CASToken *)operation {
    return [self testForTokenType:CASTokenTypeOperator transformValueBlock:^id(NSString *value, NSTextCheckingResult *match) {
        return [self.str substringWithRange:[match rangeAtIndex:1]];
    }];
}

- (CASToken *)space {
    return [self testForTokenType:CASTokenTypeSpace transformValueBlock:^id(NSString *value, NSTextCheckingResult *match) {
        return value;
    }];
}

- (CASToken *)selector {
    return [self testForTokenType:CASTokenTypeSelector transformValueBlock:^id(NSString *value, NSTextCheckingResult *match) {
        return value;
    }];
}

#pragma mark - helpers

- (CASToken *)testForTokenType:(CASTokenType)tokenType transformValueBlock:(id(^)(NSString *value, NSTextCheckingResult *match))transformValueBlock {
    return [self testForTokenType:tokenType tokenClass:CASToken.class transformValueBlock:transformValueBlock];
}

- (CASToken *)testForTokenType:(CASTokenType)tokenType tokenClass:(Class)tokenClass transformValueBlock:(id(^)(NSString *value, NSTextCheckingResult *match))transformValueBlock {
    NSArray *regexes = self.regexCache[@(tokenType)];
    NSAssert(regexes.count, @"Invalid cache. No cached regex for CASTokenType `%@`", [CASToken stringForType:tokenType]);
    for (NSRegularExpression *regex in regexes) {
        NSTextCheckingResult *match = [regex firstMatchInString:self.str options:0 range:NSMakeRange(0, self.str.length)];
        if (match) {
            CASToken *token = [tokenClass tokenOfType:tokenType];
            if (transformValueBlock) {
                token.value = transformValueBlock([self.str substringWithRange:match.range], match);
            }
            [self skip:match.range.length];
            return token;
        }
    }
    return nil;
}

@end
