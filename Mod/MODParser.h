//
//  MODParser.h
//  Mod
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MODLexer.h"

extern NSString * const MODParseFailingFilePathErrorKey;
extern NSInteger const MODParseErrorFileContents;

@interface MODParser : NSObject

/**
 *  Return style data from the given file path
 */
+ (NSArray *)stylesFromFilePath:(NSString *)filePath error:(NSError **)error;

@end
