//
//  UITextField+MODAdditions.m
//  Mod
//
//  Created by Jonas Budelmann on 14/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "UITextField+MODAdditions.h"

@implementation UITextField (MODAdditions)

#pragma mark - font properties

//@property (nonatomic, strong) NSString *mod_fontName;
//@property (nonatomic, strong) CGFloat *mod_fontSize;

- (void)setMod_fontName:(NSString *)fontName {
    self.font = [UIFont fontWithName:fontName size:self.mod_fontSize];
}

- (NSString *)mod_fontName {
    return self.font.fontName;
}

- (void)setMod_fontSize:(CGFloat)fontSize {
    if (self.mod_fontName) {
        self.font = [UIFont fontWithName:self.mod_fontName size:fontSize];
    } else {
        self.font = [UIFont systemFontOfSize:fontSize];
    }
}

- (CGFloat)mod_fontSize {
    return self.font.pointSize;
}

@end
