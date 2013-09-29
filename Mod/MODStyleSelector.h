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
    MODStyleSelectorTypeViewClass    = 1 << 0,
    MODStyleSelectorTypeStyleClass   = 1 << 1,
    MODStyleSelectorTypePseudo       = 1 << 2,
};

@interface MODStyleSelector : NSObject

@property (nonatomic, assign, readonly) MODStyleSelectorType type;
@property (nonatomic, strong, readonly) Class viewClass;
@property (nonatomic, strong, readonly) NSString *styleClass;
@property (nonatomic, strong, readonly) NSString *pseudo;
@property (nonatomic, strong, readonly) NSString *string;
@property (nonatomic, strong) MODStyleNode *node;

- (id)initWithString:(NSString *)string;

- (BOOL)shouldSelectView:(UIView *)view;

@end
