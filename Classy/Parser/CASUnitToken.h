//
//  CASUnitToken.h
//  Classy
//
//  Created by Jonas Budelmann on 23/11/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASToken.h"

@interface CASUnitToken : CASToken

@property (nonatomic, copy) NSString *suffix;
@property (nonatomic, copy) NSString *rawValue;

@end
