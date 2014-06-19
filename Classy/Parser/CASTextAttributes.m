//
//  CASTextAttributes.m
//  
//
//  Created by Jonas Budelmann on 4/11/13.
//
//

#import "CASTextAttributes.h"
#import "CASUtilities.h"

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

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    if (CASKeyDeviceSystemMajorVersion() < 7) {
        if (self.font) {
            dictionary[UITextAttributeFont] = self.font;
        }
        if (self.foregroundColor) {
            dictionary[UITextAttributeTextColor] = self.foregroundColor;
        }
        if (_shadow.shadowColor) {
            dictionary[UITextAttributeTextShadowColor] = _shadow.shadowColor;
        }
        dictionary[UITextAttributeTextShadowOffset] = [NSValue valueWithCGSize:_shadow.shadowOffset];
    }
#endif
    return dictionary;
}

@end
