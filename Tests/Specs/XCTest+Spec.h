//
//  Spec.h
//  ClassyTests
//
//  Created by Jonas Budelmann on 18/10/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>

#define SpecBegin(name) \
@interface Spec_##name : XCTestCase @end \
@implementation Spec_##name

#define SpecEnd \
@end

#define it(name, block) \
- (void)test##name { \
    block(); \
}\

//this makes above work! bizzaro
#define stuff(...)