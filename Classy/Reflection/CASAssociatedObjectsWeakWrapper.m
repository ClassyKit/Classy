//
//  CASAssociatedObjectsWeakWrapper.m
//  Pods
//
//  Created by apple on 14/11/20.
//
//

#import "CASAssociatedObjectsWeakWrapper.h"

@implementation CASAssociatedObjectsWeakWrapper

- (id)initWithWeakObject:(id)weakObject
{
  self = [super init];
  if (!self)
  {
    return nil;
  }
  
  _weakObject = weakObject;
  return self;
}

@end
