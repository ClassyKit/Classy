//
//  CASObjectClassDescriptor.h
//  Classy
//
//  Created by Jonas Budelmann on 30/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CASPropertyDescriptor.h"

@interface CASObjectClassDescriptor : NSObject

/**
 *  object class which receiver relates to
 */
@property (nonatomic, strong, readonly) Class objectClass;

/**
 *  view superclass descriptor
 */
@property (nonatomic, strong) CASObjectClassDescriptor *parent;

/**
 *  alternative names for view property keys
 */
@property (nonatomic, strong) NSDictionary *propertyKeyAliases;

- (id)initWithClass:(Class)aClass;

- (NSInvocation *)invocationForPropertyDescriptor:(CASPropertyDescriptor *)propertyDescriptor;

- (CASPropertyDescriptor *)propertyDescriptorForKey:(NSString *)key;

- (void)setArgumentDescriptors:(NSArray *)argumentDescriptors forPropertyKey:(NSString *)key;
- (void)setArgumentDescriptors:(NSArray *)argumentDescriptors setter:(SEL)setter forPropertyKey:(NSString *)key;

@end
