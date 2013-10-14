//
//  UITextField+MODAdditions.h
//  Mod
//
//  Created by Jonas Budelmann on 14/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>

//font-color (Color)
//font-name (FontName)
//font-size (Number)
//padding (Box)
//vertical-align (VerticalAlign)
//textAlignment
//setContentVerticalAlignment

@interface UITextField (MODAdditions)

@property (nonatomic, strong) NSString *mod_fontName;
@property (nonatomic, assign) CGFloat mod_fontSize;

@end
