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
@property (nonatomic, assign, readonly) BOOL immediateSuperviewOnly;
@property (nonatomic, strong) MODStyleNode *node;

- (id)initWithString:(NSString *)string;

/**
 *  Returns a integer representation of how specific this selector is.
 *  Provides a way to order selectors.
 *
 *  The Rules
 *
 *  ViewClass matches
 *   if UIKit class
 *    +0 view is a very generic UIKit class `UIView`, `UIControl`, `UIResponder`
 *    +1 view is any other UIKit class
 *
 *   else
 *    +2 any superview
 *    +3 immediate superview
 *    +4 view
 *
 *  StyleClass matches
 *   +1000 any superview
 *   +2000 immediate superview
 *   +3000 view
 *
 *  @return Precendence score
 */
- (NSUInteger)precedence;

@end
