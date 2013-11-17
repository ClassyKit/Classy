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
#import "UIBarItem+CASAdditions.h"

@implementation UITabBar (CASAdditions)

- (void)cas_updateStyling {
    [super cas_updateStyling];

    for (UITabBarItem *item in self.items) {
        item.cas_parent = self;
        [item cas_updateStyling];
    }
}

@end