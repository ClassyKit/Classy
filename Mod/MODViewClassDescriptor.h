//
//  MODViewClassDescriptor.h
//  Mod
//
//  Created by Jonas Budelmann on 30/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MODPropertyDescriptor.h"

@interface MODViewClassDescriptor : NSObject

/**
 *  view class which receiver relates to
 */
@property (nonatomic, strong, readonly) Class viewClass;

/**
 *  view superclass descriptor
 */
@property (nonatomic, strong) MODViewClassDescriptor *parent;

/**
 *  alternative names for view property keys
 */
@property (nonatomic, strong) NSDictionary *propertyKeyAliases;

- (id)initWithClass:(Class)class;

- (NSInvocation *)invocationForPropertyDescriptor:(MODPropertyDescriptor *)propertyDescriptor;

- (MODPropertyDescriptor *)propertyDescriptorForKey:(NSString *)key;

@end
