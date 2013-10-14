//
//  MODViewClassDescriptor.m
//  Mod
//
//  Created by Jonas Budelmann on 30/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODViewClassDescriptor.h"
#import "MODRuntimeExtensions.h"
#import "NSString+MODAdditions.h"

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

#pragma mark - property descriptor support

- (void)setPropertyType:(MODArgumentDescriptor *)argDescriptor forKey:(NSString *)key {
    MODPropertyDescriptor *propertyDescriptor = [[MODPropertyDescriptor alloc] initWithKey:key];
    propertyDescriptor.argumentDescriptors = @[argDescriptor];

    NSString *setter = [NSString stringWithFormat:@"set%@:", [key mod_stringByCapitalizingFirstLetter]];

    propertyDescriptor.setter = NSSelectorFromString(setter);
    self.propertyDescriptorCache[key] = propertyDescriptor;
}

- (NSInvocation *)invocationForPropertyDescriptor:(MODPropertyDescriptor *)propertyDescriptor {
    if (!propertyDescriptor) return nil;
    
    SEL selector = propertyDescriptor.setter;
    NSMethodSignature *methodSignature = [self.viewClass instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setSelector:selector];
    return invocation;
}

- (MODPropertyDescriptor *)propertyDescriptorForKey:(NSString *)key {
    //if property descriptor exists on this class descriptor. return it.
    NSString *propertyKey = self.propertyKeyAliases[key] ?: key;
    MODPropertyDescriptor *propertyDescriptor = self.propertyDescriptorCache[propertyKey];
    if (propertyDescriptor) return propertyDescriptor;

    //if property descriptor exists on parent class descriptor. return it.
    propertyDescriptor = [self.parent propertyDescriptorForKey:key];
    if (propertyDescriptor) return propertyDescriptor;

    //create property descriptor on this descriptor if has propertyKeyAlias
    //or if responds to property and superclass doesn't
    SEL propertySelector = NSSelectorFromString(propertyKey);

    if (self.propertyKeyAliases[propertyKey]
        || ([self.viewClass instancesRespondToSelector:propertySelector] && ![self.viewClass.superclass instancesRespondToSelector:propertySelector])) {
        propertyDescriptor = [[MODPropertyDescriptor alloc] initWithKey:propertyKey];

        objc_property_t property = class_getProperty(self.viewClass, [propertyKey UTF8String]);
        if (property != NULL) {
            mod_propertyAttributes *propertyAttributes = mod_copyPropertyAttributes(class_getProperty(self.viewClass, [propertyKey UTF8String]));
            if (!propertyAttributes->readonly) {
                if (propertyAttributes->objectClass) {
                    propertyDescriptor.argumentDescriptors = @[
                        [MODArgumentDescriptor argWithClass:propertyAttributes->objectClass]
                    ];
                } else {
                    NSString *type = [NSString stringWithCString:propertyAttributes->type encoding:NSASCIIStringEncoding];
                    propertyDescriptor.argumentDescriptors = @[
                        [MODArgumentDescriptor argWithType:type]
                    ];
                }
                propertyDescriptor.setter = propertyAttributes->setter;
            }
            free(propertyAttributes);

            self.propertyDescriptorCache[propertyKey] = propertyDescriptor;
            return propertyDescriptor;
        } else {
            //TODO error
        }
    }

    return nil;
}

@end
