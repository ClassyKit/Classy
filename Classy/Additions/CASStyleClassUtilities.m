//
//  CASStyleClassUtilities.m
//  Pods
//
//  Created by Jonas Budelmann on 27/03/14.
//
//

#import "CASStyleClassUtilities.h"
#import <objc/runtime.h>
#import "CASStyleableItem.h"


static void *CASStyleClassesKey = &CASStyleClassesKey;

@implementation CASStyleClassUtilities

+ (NSString *)styleClassForItem:(id<CASStyleableItem>)item {
    NSMutableSet *styleClasses = [self styleClassesForItem:item];
    return [styleClasses.allObjects componentsJoinedByString:CASStyleClassSeparator];
}

+ (void)setStyleClass:(NSString *)styleClass forItem:(id<CASStyleableItem>)item {
    NSArray *classCandidates = [styleClass componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableSet *styleClasses = [self styleClassesForItem:item];
    [styleClasses removeAllObjects];

    if (!classCandidates.count) {
        [self setStyleClasses:nil forItem:item];
        return;
    }
    if (!styleClasses) {
        styleClasses = [NSMutableSet set];
        [self setStyleClasses:styleClasses forItem:item];
    }
    for (NSString *styleClass in classCandidates) {
        if ([styleClass isKindOfClass:NSString.class] && styleClass.length) {
            [styleClasses addObject:styleClass];
        }
    }
}

+ (NSMutableSet *)styleClassesForItem:(id<CASStyleableItem>)item {
    return objc_getAssociatedObject(item, CASStyleClassesKey);
}

+ (void)setStyleClasses:(NSMutableSet *)styleClasses forItem:(id<CASStyleableItem>)item {
    objc_setAssociatedObject(item, CASStyleClassesKey, styleClasses, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)addStyleClass:(NSString *)styleClass forItem:(id<CASStyleableItem>)item {
    if (![styleClass isKindOfClass:NSString.class] || !styleClass.length) return;

    NSMutableSet *styleClasses = [self styleClassesForItem:item];
    if (!styleClasses) {
        styleClasses = [NSMutableSet set];
        [self setStyleClasses:styleClasses forItem:item];
    }
    [styleClasses addObject:styleClass];
}

+ (void)removeStyleClass:(NSString *)styleClass forItem:(id<CASStyleableItem>)item {
    if (![styleClass isKindOfClass:NSString.class] || !styleClass.length) return;

    NSMutableSet *styleClasses = [self styleClassesForItem:item];
    [styleClasses removeObject:styleClass];
}

+ (BOOL)item:(id<CASStyleableItem>)item hasStyleClass:(NSString *)styleClass {
    return [[self styleClassesForItem:item] containsObject:styleClass];
}

@end
