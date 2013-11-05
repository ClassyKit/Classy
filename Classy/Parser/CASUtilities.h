//
//  CASUtilities.h
//  
//
//  Created by Jonas Budelmann on 22/10/13.
//
//

#import <Foundation/Foundation.h>

// Logging
#ifdef DEBUG
#   define CASLog(fmt, ...) NSLog((@"[Classy] %s " fmt), __PRETTY_FUNCTION__, ##__VA_ARGS__);
#else
#   define CASLog(...)
#endif

// Keypath compile check
#define cas_propertykey(classname, property) \
(((void)(NO && ((void)(( classname *)(nil)).property, NO)), # property))

// Path resolution
#define CASAbsoluteFilePath(relativePath) \
_CASAbsoluteFilePath(__FILE__, relativePath)
NSString *_CASAbsoluteFilePath(const char *currentFilePath, NSString *relativeFilePath);

// Device versions
NSUInteger CASKeyDeviceSystemMajorVersion();

BOOL CASDeviceSystemVersionIsEqualTo(NSString *systemVersion);

BOOL CASDeviceSystemVersionIsGreaterThan(NSString *systemVersion);

BOOL CASDeviceSystemVersionIsGreaterThanOrEqualTo(NSString *systemVersion);

BOOL CASDeviceSystemVersionIsLessThan(NSString *systemVersion);

BOOL CASDeviceSystemVersionIsLessThanOrEqualTo(NSString *systemVersion);