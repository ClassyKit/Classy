//
//  MODViewClassDescriptor.m
//  Mod
//
//  Created by Jonas Budelmann on 30/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODViewClassDescriptor.h"
#import <objc/runtime.h>

@interface MODViewClassDescriptor ()

@property (nonatomic, strong, readwrite) Class viewClass;
@property (nonatomic, strong) NSMutableDictionary *propertyDescriptorCache;

@end

@implementation MODViewClassDescriptor

- (id)initWithClass:(Class)class {
    self = [super init];
    if (!self) return nil;

    self.viewClass = class;
    self.propertyDescriptorCache = NSMutableDictionary.new;

    return self;
}


#pragma mark - subscripting

- (MODPropertyDescriptor *)objectForKeyedSubscript:(NSString *)key {
    //if property descriptor exists on this class descriptor. return it.
    NSString *propertyKey = self.propertyKeyAliases[key] ?: key;
    MODPropertyDescriptor *propertyDescriptor = self.propertyDescriptorCache[propertyKey];
    if (propertyDescriptor) return propertyDescriptor;

    //if property descriptor exists on parent class descriptor. return it.
    propertyDescriptor = [self.parent objectForKeyedSubscript:key];
    if (propertyDescriptor) return propertyDescriptor;

    //create property descriptor on this descriptor if has propertyKeyAlias
    //or if responds to property and superclass doesn't
    SEL propertySelector = NSSelectorFromString(propertyKey);

    if (self.propertyKeyAliases[propertyKey]
        || ([self.viewClass instancesRespondToSelector:propertySelector] && ![self.viewClass.superclass instancesRespondToSelector:propertySelector])) {
        propertyDescriptor = [[MODPropertyDescriptor alloc] initWithKey:propertyKey];
        objc_property_t property = class_getProperty(self.viewClass, [propertyKey UTF8String]);
        if (property != NULL) {
            propertyDescriptor.argumentDescriptors = @[[MODArgumentDescriptor argWithObjCType:property_getAttributes(property)]];
        } else {
            //TODO error
        }
        self.propertyDescriptorCache[propertyKey] = propertyDescriptor;
    }

    return nil;
}

@end
