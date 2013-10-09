//
//  MODStyleSelector.h
//  Mod
//
//  Created by Jonas Budelmann on 29/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MODStyleNode.h"

@interface MODStyleSelector : NSObject

@property (nonatomic, strong) Class viewClass;
@property (nonatomic, strong) NSString *styleClass;
@property (nonatomic, assign) BOOL shouldSelectSubclasses;
@property (nonatomic, assign) BOOL shouldSelectDescendants;
@property (nonatomic, strong) MODStyleNode *node;
@property (nonatomic, strong) MODStyleSelector *parentSelector;
@property (nonatomic, weak) MODStyleSelector *childSelector;

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

- (void)setArgumentValue:(MODToken *)argumentValue forKey:(MODToken *)key;

- (NSString *)stringValue;

@end
