//
//  UIView+CASAdditions.h
//  Classy
//
//  Created by Jonas Budelmann on 30/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CASStyleableItem.h"

@interface UIView (CASAdditions) <CASStyleableItem>

@property (nonatomic, weak, readwrite) id<CASStyleableItem> cas_alternativeParent;

- (void)cas_setNeedsUpdateStylingForSubviews;

/**
 *  Same as cas_updateStyling, but by setting skipOffscreen to NO you can force styling of an
 *  item even if it is not added to a window yet.
 *  This can be useful for a number of reasons. For instance if you need to calculate the height
 *  of a UITableViewCell using AutoLayout and the layout depends on the font size in a label.
 */
- (void)cas_updateStylingSkipOffscreen:(BOOL)skipOffscreen;

@end