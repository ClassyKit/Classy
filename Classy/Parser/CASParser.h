//
//  CASParser.h
//  Classy
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CASLexer.h"

extern NSString * const CASParseFailingFilePathErrorKey;
extern NSInteger const CASParseErrorFileContents;

@interface CASParser : NSObject

/**
 *  Return style data from the given file path
 */
+ (NSArray *)styleNodesFromFilePath:(NSString *)filePath error:(NSError **)error;

@end
