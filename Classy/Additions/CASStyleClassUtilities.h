//
//  CASStyleClassUtilities.h
//  Pods
//
//  Created by Jonas Budelmann on 27/03/14.
//
//

#import <Foundation/Foundation.h>
#import "CASStyleableItem.h"

@interface CASStyleClassUtilities : NSObject

+ (NSString *)styleClassForItem:(id<CASStyleableItem>)item;

+ (void)setStyleClass:(NSString *)styleClass forItem:(id<CASStyleableItem>)item;

+ (NSMutableSet *)styleClassesForItem:(id<CASStyleableItem>)item;

+ (void)setStyleClasses:(NSMutableSet *)styleClasses forItem:(id<CASStyleableItem>)item;

+ (void)addStyleClass:(NSString *)styleClass forItem:(id<CASStyleableItem>)item;

+ (void)removeStyleClass:(NSString *)styleClass forItem:(id<CASStyleableItem>)item;

+ (BOOL)item:(id<CASStyleableItem>)item hasStyleClass:(NSString *)styleClass;

@end
