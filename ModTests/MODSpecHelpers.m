//
//  MODSpecHelpers.m
//  Mod
//
//  Created by Jonas Budelmann on 15/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODSpecHelpers.h"

//TODO could switch to fake app bundle to avoid these hacks
//http://www.cocoanetics.com/2013/10/radar-double-feature-xcode-crash-and-unit-test-with-uifont/

@implementation UIImage (MODTestAdditions)

//Will not return images in test bundle, so override to return blank image
+ (UIImage *)imageNamed:(NSString *)name {
    return name.length ? UIImage.new : nil;
}

@end

@implementation UIFont (MODTestAdditions)

//Prevent unit tests from crashing
+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize {
    UIFont *mockFont = mock(UIFont.class);
    [given([mockFont pointSize]) willReturnDouble:fontSize];
    return mockFont;
}

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize {
    UIFont *mockFont = mock(UIFont.class);
    [given([mockFont pointSize]) willReturnDouble:fontSize];
    return mockFont;
}

@end
