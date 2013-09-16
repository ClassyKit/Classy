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

@end

@implementation MODLexer

- (id)initWithString:(NSString *)str {
    self = [super init];
    if (!self) return nil;

    self.str = [str mutableCopy];
    self.stash = NSMutableArray.new;
    self.indentStack = NSMutableArray.new;

    [MODRegex(@"\\r\\n?") mod_replaceMatchesInString:self.str withTemplate:@"\n"];

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
        ?: self.seperator;
}

- (MODToken *)stashed {
    //Return the next stashed token and remove it from stash.
    MODToken *token = [self.stash firstObject];
    if (self.stash.count) {
        [self.stash removeObjectAtIndex:0];
    }
    return token;
}

#pragma mark - tokens

/**
 * EOS | trailing outdents.
 */
- (MODToken *)eos {
    if (self.str.length) return nil;
    if (self.indentStack.count) {
        [self.indentStack removeObjectAtIndex:0];
        return [[MODToken alloc] initWithType:MODTokenTypeOutdent];
    } else {
        return [[MODToken alloc] initWithType:MODTokenTypeEOS];
    }
}

/**
 * semicolon followed by any number of tabs or spaces
 */
- (MODToken *)seperator {
//    var captures;
//    if (captures = /^;[ \t]*/.exec(this.str)) {
//        this.skip(captures);
        return [[MODToken alloc] initWithType:MODTokenTypeSemiColon];
//    }
}

@end
