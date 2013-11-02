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

NSUInteger CASKeyDeviceSystemMajorVersion() {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[UIDevice.currentDevice.systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

BOOL CASDeviceSystemVersionIsEqualTo(NSString *systemVersion) {
    return [UIDevice.currentDevice.systemVersion compare:systemVersion options:NSNumericSearch] == NSOrderedSame;
}

BOOL CASDeviceSystemVersionIsGreaterThan(NSString *systemVersion) {
    return [UIDevice.currentDevice.systemVersion compare:systemVersion options:NSNumericSearch] == NSOrderedDescending;
}

BOOL CASDeviceSystemVersionIsGreaterThanOrEqualTo(NSString *systemVersion) {
    return [UIDevice.currentDevice.systemVersion compare:systemVersion options:NSNumericSearch] != NSOrderedAscending;
}

BOOL CASDeviceSystemVersionIsLessThan(NSString *systemVersion) {
    return [UIDevice.currentDevice.systemVersion compare:systemVersion options:NSNumericSearch] == NSOrderedAscending;
}

BOOL CASDeviceSystemVersionIsLessThanOrEqualTo(NSString *systemVersion) {
    return [UIDevice.currentDevice.systemVersion compare:systemVersion options:NSNumericSearch] != NSOrderedDescending;
}
