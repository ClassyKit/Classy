//
//  UITextField+CASAdditions.h
//  Classy
//
//  Created by Jonas Budelmann on 14/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (CASAdditions)

@property (nonatomic, strong) NSString *cas_fontName;
@property (nonatomic, assign) CGFloat cas_fontSize;
@property (nonatomic, assign) UIEdgeInsets cas_textEdgeInsets;

@end
