//
//  UIToolbar+CASAdditions.m
//  
//
//  Created by Jonas Budelmann on 1/11/13.
//
//

#import "UIToolbar+CASAdditions.h"

#import "CASStyler.h"
#import "UIView+CASAdditions.h"
#import "UIBarButtonItem+CASAdditions.h"

@implementation UIToolbar (CASAdditions)

- (void)cas_applyStyle:(CASStyler *)styler {
    [super cas_applyStyle:styler];

    for (UIBarButtonItem *item in self.items) {
        item.cas_parent = self;
        [styler styleItem:item];
    }
}

@end