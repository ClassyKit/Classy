//
//  MODStyleGroup.h
//  Mod
//
//  Created by Jonas Budelmann on 25/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MODStyleProperty.h"

@interface MODStyleGroup : NSObject

- (void)addSelector:(NSString *)selector;
- (void)addStyleProperty:(MODStyleProperty *)styleProperty;

@end
