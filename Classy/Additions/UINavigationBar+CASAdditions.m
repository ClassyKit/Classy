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
#import "UIBarButtonItem+CASAdditions.h"

@implementation UINavigationBar (CASAdditions)

- (void)cas_applyStyle:(CASStyler *)styler {
    [super cas_applyStyle:styler];
    
    for (UINavigationItem *navigationItem in self.items) {
        for (UIBarButtonItem *barButtonItem in navigationItem.leftBarButtonItems) {
            barButtonItem.cas_parent = self;
            [styler styleItem:barButtonItem];
        }
        for (UIBarButtonItem *barButtonItem in navigationItem.rightBarButtonItems) {
            barButtonItem.cas_parent = self;
            [styler styleItem:barButtonItem];
        }
    }
}

@end
