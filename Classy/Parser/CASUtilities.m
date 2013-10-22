//
//  CASUtilities.m
//  
//
//  Created by Jonas Budelmann on 22/10/13.
//
//

#import "CASUtilities.h"

NSString *_CASAbsoluteFilePath(const char *currentFilePath, NSString *relativeFilePath) {
    NSString *currentDirectory = [[NSString stringWithUTF8String:currentFilePath] stringByDeletingLastPathComponent];
    return [currentDirectory stringByAppendingPathComponent:relativeFilePath];
}