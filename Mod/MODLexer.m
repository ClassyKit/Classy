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

NSString * const MODParseErrorDomain = @"MODParseErrorDomain";
NSInteger const MODParseErrorInvalidToken = 1;
NSInteger const MODParseErrorInvalidIndentation = 2;
NSString * const MODParseFailingLineNumberErrorKey = @"MODParseFailingLineNumberErrorKey";
NSString * const MODParseFailingStringErrorKey = @"MODParseFailingStringErrorKey";

@interface MODLexer ()

@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, strong) NSMutableString *str;
@property (nonatomic, strong) NSMutableArray *stash;
@property (nonatomic, strong) NSMutableArray *indentStack;
@property (nonatomic, strong) MODToken *previousToken;
@property (nonatomic, strong) NSDictionary *regexCache;
@property (nonatomic, strong) NSRegularExpression *indentRegex;
@property (nonatomic, assign) NSInteger lineNumber;

@end

@implementation MODLexer

- (id)initWithString:(NSString *)str {
    self = [super init];
    if (!self) return nil;

    self.str = [str mutableCopy];
    self.stash = NSMutableArray.new;
    self.indentStack = NSMutableArray.new;
    self.lineNumber = 1;

    // replace carriage returns (\r\n | \r) with newlines
    [MODRegex(@"\\r\\n?") mod_replaceMatchesInString:self.str withTemplate:@"\n"];
    
    // trim whitespace & newlines from end of string
    [MODRegex(@"\\s+$") mod_replaceMatchesInString:self.str withTemplate:@"\n"];

    NSString *units = [@[@"pt", @"px"] componentsJoinedByString:@"|"];

    // cache regex's
    self.regexCache = @{

        // 1 of `;` followed by 0-* of whitespace
        @(MODTokenTypeSemiColon) : @[ MODRegex(@"^;[ \\t]*") ],

        // new line followed by tabs or spaces
        @(MODTokenTypeIndent)   : @[ MODRegex(@"^\\n([\\t]*)"),
                                     MODRegex(@"^\\n([ ]*)") ],

        //#rrggbbaa | #rrggbb | #rgb
        @(MODTokenTypeColor)     : @[ MODRegex(@"^#([a-fA-F0-9]{8})[ \\t]*"),
                                      MODRegex(@"^#([a-fA-F0-9]{6})[ \\t]*"),
                                      MODRegex(@"^#([a-fA-F0-9]{3})[ \\t]*") ],

        // string enclosed in single or double quotes
        @(MODTokenTypeString)    : @[ MODRegex(@"^(\"[^\"]*\"|'[^']*')[ \\t]*") ],

        // decimal/integer number with optional (px, pt) suffix
        @(MODTokenTypeUnit)      : @[ MODRegex(@"^(-)?(\\d+\\.\\d+|\\d+|\\.\\d+)(%@)?[ \\t]*", units) ],

        // true | false | YES | NO
        @(MODTokenTypeBoolean)   : @[ MODRegex(@"^(true|false|YES|NO)\\b([ \\t]*)") ],

        // optional `@` | `-` then at least one `_a-zA-Z$` following by any alphanumber or `-` or `$`
        @(MODTokenTypeRef)       : @[ MODRegex(@"^(@)?(-*[_a-zA-Z$][-\\w\\d$]*)") ],

        // tests if string looks like math operation
        @(MODTokenTypeOperator) : @[ MODRegex(@"^([.]{2,3}|&&|\\|\\||[!<>=?:]=|\\*\\*|[-+*\\/%%]=?|[,=?:!~<>&\\[\\]])([ \\t]*)") ],

        // 1-* of whitespace
        @(MODTokenTypeSpace)     : @[ MODRegex(@"^([ \\t]+)") ],

        // any character except `\n` | `{` | `,` and stop if encounter `//` unless its inbetween `[ ]`
        @(MODTokenTypeSelector)  : @[ MODRegex(@"^.*?(?=\\/\\/(?![^\\[]*\\])|[,\\n{])") ]
    };

    return self;
}

- (MODToken *)peekToken {
    return [self lookaheadByCount:1];
}

- (MODToken *)nextToken {
    MODToken *token = self.popToken;
    if (!token) {
        token = self.advanceToken;
        [self attachDebugInfoForToken:token];
    }
    self.previousToken = token;
    return token;
}

- (MODToken *)lookaheadByCount:(NSUInteger)count {
    NSAssert(count > 0, @"Invalid lookahead. Count `%d` must be >= 1", count);
    NSInteger fetch = count - self.stash.count;
    while (fetch-- > 0) {
        MODToken *token = self.advanceToken;
        if (!token) {
            return nil;
        }
        [self attachDebugInfoForToken:token];
        [self.stash addObject:token];
    }
    return self.stash[count-1];
}

- (void)attachDebugInfoForToken:(MODToken *)token {
    switch (token.type) {
        case MODTokenTypeNewline:
        case MODTokenTypeIndent:
            ++self.lineNumber;
            break;
        case MODTokenTypeOutdent:
            if (MODTokenTypeOutdent != self.previousToken.type) ++self.lineNumber;
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
        MODParseFailingLineNumberErrorKey: @(self.lineNumber),
        MODParseFailingStringErrorKey: string
    };
    return [NSError errorWithDomain:MODParseErrorDomain code:code userInfo:userInfo];
}

#pragma mark - private

- (void)skip:(NSUInteger)n {
    [self.str deleteCharactersInRange:NSMakeRange(0, n)];
}

- (MODToken *)advanceToken {
    // TODO optimise
    // this could possibly be faster using simple string scanning (NSScanner), instead of regex
    // however all these regexs are anchored to start of string so should be fairly quick
    MODToken *token = self.eos
        ?: self.seperator
        ?: self.comment
        ?: self.newline
        ?: self.brace
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
                                           code:MODParseErrorInvalidToken];
        return nil;
    }

    return token;
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
        return [MODToken tokenOfType:MODTokenTypeOutdent];
    } else {
        return [MODToken tokenOfType:MODTokenTypeEOS];
    }
}

- (MODToken *)seperator {
    return [self testForTokenType:MODTokenTypeSemiColon transformValueBlock:nil];
}

- (MODToken *)comment {
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

- (MODToken *)newline {
    // we have established the indentation regexp
    NSTextCheckingResult *match;
    if (self.indentRegex){
        match = [self.indentRegex firstMatchInString:self.str options:0 range:NSMakeRange(0, self.str.length)];
    } else {
        // figure out if we are using tabs or spaces
        for (NSRegularExpression *regex in self.regexCache[@(MODTokenTypeIndent)]) {
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
                                           code:MODParseErrorInvalidIndentation];
        return nil;
    }

    // Blank line
    if ([self.str hasPrefix:@"\n"]) {
        ++self.lineNumber;
        return self.advanceToken;
    }

    NSInteger indents = [match rangeAtIndex:1].length;
    MODToken *token;
    if (self.indentStack.count && indents < [self.indentStack[0] integerValue]) {
        while (self.indentStack.count && [self.indentStack[0] integerValue] > indents) {
            [self.stash insertObject:[MODToken tokenOfType:MODTokenTypeOutdent] atIndex:0];
            [self.indentStack removeObjectAtIndex:0];
        }
        token = [self popToken];
    } else if (indents && indents != (self.indentStack.count ? [self.indentStack[0] integerValue] : 0)) {
        [self.indentStack insertObject:@(indents) atIndex:0];
        token = [MODToken tokenOfType:MODTokenTypeIndent];
    } else {
        token = [MODToken tokenOfType:MODTokenTypeNewline];
    }
    
    return token;
}

- (MODToken *)brace {
    if ([self.str hasPrefix:@"{"]) {
        [self skip:1];
        return [MODToken tokenOfType:MODTokenTypeOpeningBrace];
    }
    if ([self.str hasPrefix:@"}"]) {
        [self skip:1];
        return [MODToken tokenOfType:MODTokenTypeClosingBrace];
    }
    return nil;
}

- (MODToken *)color {
    return [self testForTokenType:MODTokenTypeColor transformValueBlock:^id(NSString *value, NSTextCheckingResult *match) {
        return [UIColor mod_colorWithHex:[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }];
}

- (MODToken *)string {
    return [self testForTokenType:MODTokenTypeString transformValueBlock:^id(NSString *value, NSTextCheckingResult *match) {
        NSString *string = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return [string substringWithRange:NSMakeRange(1, string.length-2)];
    }];
}

- (MODToken *)unit {
    return [self testForTokenType:MODTokenTypeUnit transformValueBlock:^id(NSString *value, NSTextCheckingResult *match){
        //px,pt,% etc NSString *type = [self.str substringWithRange:[match rangeAtIndex:match.numberOfRanges-1]];
        NSString *string = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return @([string doubleValue]);
    }];
}

- (MODToken *)boolean {
    return [self testForTokenType:MODTokenTypeBoolean transformValueBlock:^id(NSString *value, NSTextCheckingResult *match) {
        return @([value hasPrefix:@"true"] || [value hasPrefix:@"YES"]);
    }];
}

- (MODToken *)ref {
    return [self testForTokenType:MODTokenTypeRef transformValueBlock:^id(NSString *value, NSTextCheckingResult *match) {
        return value;
    }];
}

- (MODToken *)operation {
    return [self testForTokenType:MODTokenTypeOperator transformValueBlock:^id(NSString *value, NSTextCheckingResult *match) {
        return [self.str substringWithRange:[match rangeAtIndex:1]];
    }];
}

- (MODToken *)space {
    return [self testForTokenType:MODTokenTypeSpace transformValueBlock:nil];
}

- (MODToken *)selector {
    return [self testForTokenType:MODTokenTypeSelector transformValueBlock:^id(NSString *value, NSTextCheckingResult *match) {
        return value;
    }];
}

#pragma mark - helpers

- (MODToken *)testForTokenType:(MODTokenType)tokenType transformValueBlock:(id(^)(NSString *value, NSTextCheckingResult *match))transformValueBlock {
    NSArray *regexes = self.regexCache[@(tokenType)];
    NSAssert(regexes.count, @"Invalid cache. No cached regex for MODTokenType `%@`", [MODToken stringForType:tokenType]);
    for (NSRegularExpression *regex in regexes) {
        NSTextCheckingResult *match = [regex firstMatchInString:self.str options:0 range:NSMakeRange(0, self.str.length)];
        if (match) {
            MODToken *token = [MODToken tokenOfType:tokenType];
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
