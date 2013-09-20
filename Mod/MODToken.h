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
    MODTokenTypeBrace,
    MODTokenTypeColor,
    MODTokenTypeString,
    MODTokenTypeUnit,
    MODTokenTypeBoolean,
    MODTokenTypeRef,
    MODTokenTypeSpace,
    MODTokenTypeSelector,
};

@interface MODToken : NSObject

@property (nonatomic, assign) MODTokenType type;
@property (nonatomic, strong) id value;

+ (NSString *)stringForType:(MODTokenType)type;

- (id)initWithType:(MODTokenType)type;
- (id)initWithType:(MODTokenType)type value:(id)value;

@end
