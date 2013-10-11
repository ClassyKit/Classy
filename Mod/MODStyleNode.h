//
//  MODStyleGroup.h
//  Mod
//
//  Created by Jonas Budelmann on 25/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MODStyleProperty.h"

@interface MODStyleNode : NSObject

/**
 *  returns all style properties for the receiver
 */
@property (nonatomic, readonly) NSArray *properties;

/**
 *  Add a style property to the receiver
 */
- (void)addStyleProperty:(MODStyleProperty *)styleProperty;

@end
