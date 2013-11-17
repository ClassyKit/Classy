//
//  UINavigationBar+CASAdditions.m
//  
//
//  Created by Jonas Budelmann on 31/10/13.
//
//

#import "UINavigationBar+CASAdditions.h"
#import "CASStyler.h"
#import "UIView+CASAdditions.h"
#import "UIBarItem+CASAdditions.h"

@implementation UINavigationBar (CASAdditions)

- (void)cas_updateStyling {
    [super cas_updateStyling];
    
    for (UINavigationItem *navigationItem in self.items) {
        for (UIBarButtonItem *barButtonItem in navigationItem.leftBarButtonItems) {
            barButtonItem.cas_parent = self;
            [barButtonItem cas_updateStyling];
        }
        for (UIBarButtonItem *barButtonItem in navigationItem.rightBarButtonItems) {
            barButtonItem.cas_parent = self;
            [barButtonItem cas_updateStyling];
        }
    }
}

@end
