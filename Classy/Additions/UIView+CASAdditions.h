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

@property (nonatomic, strong) UIColor *cas_borderColor;
@property (nonatomic, assign) CGFloat cas_borderWidth;
@property (nonatomic, assign) CGFloat cas_cornerRadius;

@property (nonatomic, strong) UIColor *cas_shadowColor;
@property (nonatomic, assign) CGSize cas_shadowOffset;
@property (nonatomic, assign) CGFloat cas_shadowOpacity;
@property (nonatomic, assign) CGFloat cas_shadowRadius;

@end