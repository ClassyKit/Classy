//
//  CASStyleableItem.h
//  
//
//  Created by Jonas Budelmann on 31/10/13.
//
//

#import <Foundation/Foundation.h>

/**
 *  separator string used to seperate multiple classes in the cas_styleClass property
 */
extern NSString *const CASStyleClassSeparator;

@protocol CASStyleableItem <NSObject>

/**
 *  NSString which should relate to a styleClass in your stylesheet
 *  multiple style classes can be set by separating them with the string defined as CASStyleClassSeparator
 *  this property will change cas_styleClasses and is a alternative accessor for the set of style classes (e.g. interface builder etc.)
 */
@property (nonatomic, copy) NSString *cas_styleClass;

/**
 *  Direct parent of receiver
 *  ie in case of UIView will be self.superview
 */
@property (nonatomic, weak, readonly) id<CASStyleableItem> cas_parent;

/**
 *  In some cases it is appropriate to specify an alternative parent relationship
 *  ie in case of UIView it's UIViewController is an alternative parent to it's superview
 */
@property (nonatomic, weak, readonly) id<CASStyleableItem> cas_alternativeParent;

/**
 *  adds a style class if it was not set previosly
 */
- (void)cas_addStyleClass:(NSString *)styleClass;

/**
 *  removes a style class if it was set previosly
 */
- (void)cas_removeStyleClass:(NSString *)styleClass;

/**
 * Returns wether or not the receiver has a specific style class assigned
 */
- (BOOL)cas_hasStyleClass:(NSString *)styleClass;

/**
 *  Peforms styling now if receiver needs styling
 */
- (void)cas_updateStylingIfNeeded;

/**
 *  Override this to adjust your styling during a style update pass.
 *  If overriding should call super
 */
- (void)cas_updateStyling;

/**
 *  Returns whether or not receiver has been marked as needing style update
 */
- (BOOL)cas_needsUpdateStyling;

/**
 *  Schedules the receiver to for a style update
 */
- (void)cas_setNeedsUpdateStyling;

@end
