//
//  CASStyleSelector.h
//  Classy
//
//  Created by Jonas Budelmann on 29/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CASStyleableItem.h"

@interface CASStyleSelector : NSObject <NSCopying>

/**
 *  Class of View to match
 */
@property (nonatomic, strong) Class objectClass;

/**
 *  If not nil checks the view's cas_styleClass property
 */
@property (nonatomic, copy) NSString *styleClass;

/**
 *  Whether or not to do strict matching against objectClass
 */
@property (nonatomic, assign) BOOL shouldSelectSubclasses;

/**
 *  Whether or not parent selector can be an indirect superview
 */
@property (nonatomic, assign) BOOL shouldSelectIndirectSuperview;

/**
 *  Whether or not this selector is a parent
 */
@property (nonatomic, assign, getter = isParent) BOOL parent;


/**
 *  Whether or not this selector should be concatenated
 */
@property (nonatomic, assign) BOOL shouldConcatToParent;

/**
 *  Provides support for properties that have extra arguments such as
 *  - setTitle:forState:
 */
@property (nonatomic, strong) NSDictionary *arguments;

/**
 *  Parent selector
 */
@property (nonatomic, strong) CASStyleSelector *parentSelector;

/**
 *  Last selector in heirachy
 */
@property (nonatomic, readonly) CASStyleSelector *lastSelector;

/**
 *  Returns a integer representation of how specific this selector is.
 *  Provides a way to order selectors.
 *
 *  The Rules
 *
 *  ObjectClass matches
 *   +2 ancestor
 *   +3 superview
 *   +4 view
 *
 *   if loose match (shouldSelectSubclasses)
 *    -1
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
 *  Whether is selector matches the given item
 *
 *  @param item `CASStyleableItem` or a subclass
 *
 *  @return `YES` if all selectors including parent selectors match the item
 */
- (BOOL)shouldSelectItem:(id<CASStyleableItem>)item;

/**
 *  String representation of receiver
 *
 *  @return a `NSString` value
 */
- (NSString *)stringValue;

@end
