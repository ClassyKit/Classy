//
//  CASViewClassDescriptor.m
//  Classy
//
//  Created by Jonas Budelmann on 30/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASViewClassDescriptor.h"
#import "CASRuntimeExtensions.h"
#import "NSString+CASAdditions.h"

@interface CASViewClassDescriptor ()

@property (nonatomic, strong, readwrite) Class viewClass;
@property (nonatomic, strong) NSMutableDictionary *propertyDescriptorCache;

@end

@implementation CASViewClassDescriptor

- (id)initWithClass:(Class)class {
    self = [super init];
    if (!self) return nil;

    self.viewClass = class;
    self.propertyDescriptorCache = NSMutableDictionary.new;

    return self;
}

#pragma mark - property descriptor support

- (void)setArgumentDescriptors:(NSArray *)argumentDescriptors forPropertyKey:(NSString *)key {
    CASPropertyDescriptor *propertyDescriptor = [[CASPropertyDescriptor alloc] initWithKey:key argumentDescriptors:argumentDescriptors];
    self.propertyDescriptorCache[propertyDescriptor.key] = propertyDescriptor;
}

- (void)setArgumentDescriptors:(NSArray *)argumentDescriptors setter:(SEL)setter forPropertyKey:(NSString *)key {
    CASPropertyDescriptor *propertyDescriptor = [[CASPropertyDescriptor alloc] initWithKey:key argumentDescriptors:argumentDescriptors setter:setter];
    self.propertyDescriptorCache[propertyDescriptor.key] = propertyDescriptor;
}

- (NSInvocation *)invocationForPropertyDescriptor:(CASPropertyDescriptor *)propertyDescriptor {
    if (!propertyDescriptor) return nil;
    
    SEL selector = propertyDescriptor.setter;
    NSMethodSignature *methodSignature = [self.viewClass instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setSelector:selector];
    return invocation;
}

- (CASPropertyDescriptor *)propertyDescriptorForKey:(NSString *)key {
    // if property descriptor exists on this class descriptor. return it.
    NSString *propertyKey = self.propertyKeyAliases[key] ?: key;
    CASPropertyDescriptor *propertyDescriptor = self.propertyDescriptorCache[propertyKey];
    if (propertyDescriptor) return propertyDescriptor;

    // if property descriptor exists on parent class descriptor. return it.
    propertyDescriptor = [self.parent propertyDescriptorForKey:key];
    if (propertyDescriptor) return propertyDescriptor;

    // create property descriptor on this descriptor if has propertyKeyAlias
    // or if responds to property and superclass doesn't
    SEL propertySelector = NSSelectorFromString(propertyKey);

    if (self.propertyKeyAliases[propertyKey]
        || ([self.viewClass instancesRespondToSelector:propertySelector] && ![self.viewClass.superclass instancesRespondToSelector:propertySelector])) {

        objc_property_t property = class_getProperty(self.viewClass, [propertyKey UTF8String]);
        if (property != NULL) {
            cas_propertyAttributes *propertyAttributes = cas_copyPropertyAttributes(class_getProperty(self.viewClass, [propertyKey UTF8String]));
            if (!propertyAttributes->readonly) {

                NSArray *argumentDescriptors;
                if (propertyAttributes->objectClass) {
                    argumentDescriptors = @[
                        [CASArgumentDescriptor argWithClass:propertyAttributes->objectClass]
                    ];
                } else {
                    NSString *type = [NSString stringWithCString:propertyAttributes->type encoding:NSASCIIStringEncoding];
                    argumentDescriptors = @[
                        [CASArgumentDescriptor argWithType:type]
                    ];
                }
                
                propertyDescriptor = [[CASPropertyDescriptor alloc] initWithKey:propertyKey argumentDescriptors:argumentDescriptors setter:propertyAttributes->setter];
                self.propertyDescriptorCache[propertyKey] = propertyDescriptor;

                free(propertyAttributes);
                return propertyDescriptor;
            } else {
                free(propertyAttributes);
                // TODO error
            }
        } else {
            // TODO error
        }
    }

    return nil;
}

@end
