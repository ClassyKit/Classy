//
//  CASStyleGroup.h
//  Classy
//
//  Created by Jonas Budelmann on 25/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CASStyleProperty.h"

@interface CASStyleNode : NSObject

/**
 *  returns all style properties for the receiver
 */
@property (nonatomic, readonly) NSArray *properties;

/**
 *  Add a style property to the receiver
 */
- (void)addStyleProperty:(CASStyleProperty *)styleProperty;

@end
