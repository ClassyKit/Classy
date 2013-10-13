//
//  UIView+MODAdditions.h
//  Mod
//
//  Created by Jonas Budelmann on 30/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MODAdditions)

@property (nonatomic, strong) NSString *mod_styleClass;

@property (nonatomic, strong) UIColor *mod_borderColor;
@property (nonatomic, assign) CGFloat mod_borderWidth;
@property (nonatomic, assign) CGFloat mod_cornerRadius;

@end