//
//  CASAssociatedObjectsWeakWrapper.h
//  Pods
//
//  Created by apple on 14/11/20.
//
//

#import <Foundation/Foundation.h>

@interface CASAssociatedObjectsWeakWrapper : NSObject
@property(nonatomic, weak, readonly) id weakObject;

- (id)initWithWeakObject:(id)weakObject;
@end

#define CASSynthesize(ownership, type, getter, setter)                         \
  static const void *_CASSynthesizeKey_##getter = &_CASSynthesizeKey_##getter; \
  -(type)getter {                                                              \
    return _CASSynthesize_get_##ownership(type, getter);                       \
  }                                                                            \
  -(void)setter : (type)getter {                                               \
    _CASSynthesize_set_##ownership(type, getter);                              \
  }

#define _CASSynthesize_get_weak(type, getter)                                  \
  ((CASAssociatedObjectsWeakWrapper *)objc_getAssociatedObject(                \
       self, _CASSynthesizeKey_##getter)).weakObject

#define _CASSynthesize_set_weak(type, getter)                                  \
  objc_setAssociatedObject(                                                    \
      self, _CASSynthesizeKey_##getter,                                        \
      [[CASAssociatedObjectsWeakWrapper alloc] initWithWeakObject:getter],     \
      OBJC_ASSOCIATION_RETAIN_NONATOMIC);
