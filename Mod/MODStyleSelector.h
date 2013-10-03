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
@property (nonatomic, assign, readonly) BOOL shouldSelectSubclasses;
@property (nonatomic, assign, readonly) BOOL shouldSelectDescendants;
@property (nonatomic, strong) MODStyleNode *node;

- (id)initWithString:(NSString *)string;

/**
 *  Returns a integer representation of how specific this selector is.
 *  Provides a way to order selectors.
 *
 *  The Rules
 *
 *  ViewClass matches
 *   +2 ancestor
 *   +3 superview
 *   +4 view
 *
 *   if loose match (shouldSelectSubclasses)
 *    -2
 *
 *  StyleClass matches
 *   +1000 ancestor
 *   +2000 superview
 *   +3000 view
 *
 *  @return Precendence score
 */
- (NSInteger)precedence;

/**
 *  Whether is selector matches the given view
 *
 *  @param view `UIView` or a subclass
 *
 *  @return `YES` if all selectors including parent selectors match the view
 */
- (BOOL)shouldSelectView:(UIView *)view;

@end
