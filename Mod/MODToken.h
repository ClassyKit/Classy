//
//  MODToken.h
//  Mod
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MODTokenType) {
    MODTokenTypeIndent,
    MODTokenTypeOutdent,
    MODTokenTypeEOS,
    MODTokenTypeSemiColon,
    MODTokenTypeNewline,
    MODTokenTypeOpeningBrace,
    MODTokenTypeClosingBrace,
    MODTokenTypeColor,
    MODTokenTypeString,
    MODTokenTypeUnit,
    MODTokenTypeBoolean,
    MODTokenTypeRef,
    MODTokenTypeOperator,
    MODTokenTypeSpace,
    MODTokenTypeSelector,
};

@interface MODToken : NSObject

@property (nonatomic, assign, readonly) MODTokenType type;
@property (nonatomic, strong) id value;
@property (nonatomic, assign) NSInteger lineNumber;

+ (NSString *)stringForType:(MODTokenType)type;

+ (instancetype)tokenOfType:(MODTokenType)type;

@end
