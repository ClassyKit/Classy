//
//  UINavigationItem+CASAdditions.m
//  
//
//  Created by Joseph Ridenour on 1/21/15.
//
//

#import "UINavigationItem+CASAdditions.h"
#import "CASStyler.h"
#import "UIBarItem+CASAdditions.h"
#import "NSObject+CASSwizzle.h"

@implementation UINavigationItem (CASAdditions)

+ (void)bootstrapClassy {
    [self cas_swizzleInstanceSelector:@selector(setRightBarButtonItem:animated:) withNewSelector:@selector(cas_setRightBarButtonItem:animated:)];
    [self cas_swizzleInstanceSelector:@selector(setLeftBarButtonItem:animated:) withNewSelector:@selector(cas_setLeftBarButtonItem:animated:)];
    
    [self cas_swizzleInstanceSelector:@selector(setLeftBarButtonItems:animated:) withNewSelector:@selector(cas_setRightBarButtonItems:animated:)];
    [self cas_swizzleInstanceSelector:@selector(setLeftBarButtonItems:animated:) withNewSelector:@selector(cas_setLeftBarButtonItems:animated:)];
}

- (void)cas_setRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    [CASStyler.defaultStyler styleItem:item];
    [self cas_setRightBarButtonItem:item animated:animated];
}

- (void)cas_setLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    [CASStyler.defaultStyler styleItem:item];
    [self cas_setLeftBarButtonItem:item animated:animated];
}

- (void)cas_setRightBarButtonItems:(NSArray *)items animated:(BOOL)animated {
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [CASStyler.defaultStyler styleItem:obj];
    }];
    [self cas_setRightBarButtonItems:items animated:animated];
}

- (void)cas_setLeftBarButtonItems:(NSArray *)items animated:(BOOL)animated {
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [CASStyler.defaultStyler styleItem:obj];
    }];
    [self cas_setLeftBarButtonItems:items animated:animated];
}

@end
