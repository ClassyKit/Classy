//
//  CASTestsAppDelegate.m
//  ClassyTests
//
//  Created by Jonas Budelmann on 19/11/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "CASTestsAppDelegate.h"

@implementation CASTestsAppDelegate

+ (void)initialize {
    [[NSUserDefaults standardUserDefaults] setValue:@"XCTestLog,GcovTestObserver"
                                             forKey:@"XCTestObserverClass"];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    extern void __gcov_flush(void);
    __gcov_flush();
}

@end
