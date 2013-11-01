//
//  UITabBar+CASAdditions.m
//  
//
//  Created by Jonas Budelmann on 1/11/13.
//
//

#import "UITabBar+CASAdditions.h"

#import "CASStyler.h"
#import "UIView+CASAdditions.h"
#import "UITabBarItem+CASAdditions.h"

@implementation UITabBar (CASAdditions)

- (void)cas_applyStyle:(CASStyler *)styler {
    [super cas_applyStyle:styler];

    for (UITabBarItem *item in self.items) {
        item.cas_parent = self;
        [styler styleItem:item];
    }
}

@end