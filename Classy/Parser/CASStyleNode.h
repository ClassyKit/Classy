//
//  CASStyleGroup.h
//  Classy
//
//  Created by Jonas Budelmann on 25/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CASStyleProperty.h"
#import "CASStyleSelector.h"
#import "CASDeviceSelector.h"

@interface CASStyleNode : NSObject

/**
 *  NSInvocations to apply to appropriate view
 */
@property (nonatomic, strong) NSArray *invocations;

/**
 *  returns all style properties for the receiver
 */
@property (nonatomic, strong, readonly) NSArray *styleProperties;

/**
 *  style selector related to this node
 */
@property (nonatomic, strong) CASStyleSelector *styleSelector;

/**
 *  device selector related to this node
 */
@property (nonatomic, strong) CASDeviceSelector *deviceSelector;

/**
 *  Add a style property to the receiver
 */
- (void)addStyleProperty:(CASStyleProperty *)styleProperty;

@end
