//
//  CASTextAttributes.m
//  
//
//  Created by Jonas Budelmann on 4/11/13.
//
//

#import "CASTextAttributes.h"

@implementation CASTextAttributes

- (NSMutableParagraphStyle *)paragraphStyle {
    if (!_paragraphStyle) {
        _paragraphStyle = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    }
    return _paragraphStyle;
}

- (NSShadow *)shadow {
    if (!_shadow) {
        _shadow = NSShadow.new;
    }
    return _shadow;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dictionary = NSMutableDictionary.new;

    if (self.font) {
        dictionary[NSFontAttributeName] = self.font;
    }

    if (_paragraphStyle) {
        dictionary[NSParagraphStyleAttributeName] = _paragraphStyle;
    }

    if (self.foregroundColor) {
        dictionary[NSForegroundColorAttributeName] = self.foregroundColor;
    }

    if (self.backgroundColor) {
        dictionary[NSBackgroundColorAttributeName] = self.backgroundColor;
    }

    dictionary[NSLigatureAttributeName] = @(self.ligature);
    dictionary[NSKernAttributeName] = @(self.kern);
    dictionary[NSStrikethroughStyleAttributeName] = @(self.strikethroughStyle);
    dictionary[NSUnderlineStyleAttributeName] = @(self.underlineStyle);
    
    if (CASKeyDeviceSystemMajorVersion() >= 7) {
        dictionary[NSBaselineOffsetAttributeName] = @(self.baselineOffset);
    }
    
    if (self.strokeColor) {
        dictionary[NSStrokeColorAttributeName] = self.strokeColor;
    }

    dictionary[NSStrokeWidthAttributeName] = @(self.strokeWidth);

    if (_shadow) {
        dictionary[NSShadowAttributeName] = _shadow;
    }

    return dictionary;
}

@end
