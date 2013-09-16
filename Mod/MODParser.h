//
//  MODParser.h
//  Mod
//
//  Created by Jonas Budelmann on 15/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const MODParserErrorDomain;
extern NSInteger const MODParserErrorFileContents;

@interface MODParser : NSObject

- (id)initWithFilePath:(NSString *)filePath error:(NSError **)error;

@end
