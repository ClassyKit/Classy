//
//  CASAppDelegate.m
//  ClassyExample
//
//  Created by Jonas Budelmann on 21/10/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "CASAppDelegate.h"
#import "CASRootViewController.h"
#import "Classy.h"

@implementation CASAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {


#if TARGET_IPHONE_SIMULATOR
    // get absolute file path of stylesheet, using relative path
    NSString *absoluteFilePath = CASAbsoluteFilePath(@"Stylesheets/stylesheet.cas");
    [CASStyler defaultStyler].watchFilePath = absoluteFilePath;
#endif
    
    
    // Move files to caches directory for referencing in stylesheet
    NSString *caches = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    NSString *path = [caches stringByAppendingPathComponent:@"Ball.png"];
    [[NSFileManager defaultManager] createDirectoryAtPath:caches withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"Ball" ofType:@"png"] toPath:path error:nil];
    
    // Move quarter to documents for testing
    

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:CASRootViewController.new];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
