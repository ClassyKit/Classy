//
//  MODStyleSelector.h
//  Mod
//
//  Created by Jonas Budelmann on 29/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MODStyleNode.h"

typedef NS_OPTIONS(NSUInteger, MODStyleSelectorType) {
    MODStyleSelectorTypeNone         = 0,
    MODStyleSelectorTypeViewClass    = 1 << 0,
    MODStyleSelectorTypeStyleClass   = 1 << 1,
    MODStyleSelectorTypePseudo       = 1 << 2,
    MODStyleSelectorTypeParent       = 1 << 3,
};

@interface MODStyleSelector : NSObject

@property (nonatomic, assign, readonly) MODStyleSelectorType type;
@property (nonatomic, assign, readonly) Class styleClass;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) MODStyleNode *node;

- (id)initWithName:(NSString *)name node:(MODStyleNode *)node;

- (BOOL)shouldSelectView:(UIView *)view;

@end
