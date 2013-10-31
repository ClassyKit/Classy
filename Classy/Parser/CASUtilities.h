//
//  CASUtilities.h
//  
//
//  Created by Jonas Budelmann on 22/10/13.
//
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#   define CASLog(fmt, ...) NSLog((@"%s " fmt), __PRETTY_FUNCTION__, ##__VA_ARGS__);
#else
#   define CASLog(...)
#endif

#define cas_propertykey(classname, property) \
(((void)(NO && ((void)(( classname *)(nil)).property, NO)), # property))

#define CASAbsoluteFilePath(relativePath) \
_CASAbsoluteFilePath(__FILE__, relativePath)

NSString *_CASAbsoluteFilePath(const char *currentFilePath, NSString *relativeFilePath);

NSUInteger CASKeyDeviceSystemMajorVersion();