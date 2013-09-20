//
//  MODToken.h
//  Mod
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MODTokenType) {
    MODTokenTypeEOS,
    MODTokenTypeNewline,
    MODTokenTypeSemiColon,
    MODTokenTypeColon,
    MODTokenTypeIndent,
    MODTokenTypeOutdent,
    MODTokenTypeSpace,
    MODTokenTypeBrace,
    MODTokenTypeColor,
    MODTokenTypeString,
    MODTokenTypeUnit,
    MODTokenTypeBoolean,
    MODTokenTypeSelector,
};

@interface MODToken : NSObject

@property (nonatomic, assign) MODTokenType type;
@property (nonatomic, strong) id value;

+ (NSString *)stringForType:(MODTokenType)type;

- (id)initWithType:(MODTokenType)type;
- (id)initWithType:(MODTokenType)type value:(id)value;

@end
