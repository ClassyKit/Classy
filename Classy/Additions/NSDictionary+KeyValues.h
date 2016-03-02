//
//  NSDictionary+KeyValues.h
//  Classy
//
//  Created by Mihail Gerasimenko on 3/2/16.
//  Copyright © 2016 Zeta Project Berlin Gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CASKeyValues)
- (NSArray *)cas_keyValues;
- (NSArray *)cas_sortedKeyValues;
@end
