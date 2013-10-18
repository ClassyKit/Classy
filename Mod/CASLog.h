//
//  CASLog.h
//  Classy
//
//  Created by Jonas Budelmann on 26/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#   define CASLog(fmt, ...) NSLog((@"%s " fmt), __PRETTY_FUNCTION__, ##__VA_ARGS__);
#else
#   define CASLog(...)
#endif

//TODO move
#define cas_propertykey(classname, property) \
(((void)(NO && ((void)(( classname *)(nil)).property, NO)), # property))