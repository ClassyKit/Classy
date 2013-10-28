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

@interface CASStyleNode : NSObject

/**
 *  returns all style properties for the receiver
 */
@property (nonatomic, readonly) NSArray *properties;

/**
 *  selector related to this node
 */
@property (nonatomic, strong) CASStyleSelector *styleSelector;

/**
 *  Add a style property to the receiver
 */
- (void)addStyleProperty:(CASStyleProperty *)styleProperty;

@end
