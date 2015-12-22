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
@property (nonatomic, copy) IBInspectable NSString *cas_styleClass;

- (void)cas_setNeedsUpdateStylingForSubviews;

@end

