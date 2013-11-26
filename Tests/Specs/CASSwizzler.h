//
//  CASSwizzler.h
//  ClassyTests
//
//  Created by Jonas Budelmann on 26/11/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

void SwizzleClassMethod(Class class, SEL orig, SEL new) {

    Method origMethod = class_getClassMethod(class, orig);
    Method newMethod = class_getClassMethod(class, new);

    class = object_getClass((id)class);

    if(class_addMethod(class, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(class, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}