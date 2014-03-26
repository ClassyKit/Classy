//
//  UISlider+CASAdditions.m
//  
//
//  Created by Cail Borrell on 19/02/14.
//
//

#import "UISlider+CASAdditions.h"
#import "NSObject+CASSwizzle.h"
#import "UIView+CASAdditions.h"

@implementation UISlider (CASAdditions)

+ (void)load {
    [self cas_swizzleInstanceSelector:@selector(didMoveToWindow)
                      withNewSelector:@selector(cas_didMoveToWindow)];
}

- (void)cas_didMoveToWindow {
    [self cas_updateStyling];
    [self cas_didMoveToWindow];
}

@end
