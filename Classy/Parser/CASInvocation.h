//
//  CASInvocation.h
//  
//
//  Created by Jonas Budelmann on 5/11/13.
//
//

#import <Foundation/Foundation.h>

@interface CASInvocation : NSObject

/**
 *  Wraps an NSInvocation with an optional keypath.
 *  If keypath is non-nil will alter the target when invokeWithTarget: is called
 *
 *  @param invocation NSInvocation to wrap
 *  @param keyPath to store for later use
 *
 *  @return CASInvocation
 */
- (id)initWithInvocation:(NSInvocation *)invocation forKeyPath:(NSString *)keyPath;

/**
 *  Invoke the wrapped NSInvocation.
 *  If keypath is non-nil target will be evaluated keypath
 *
 *  @param target root object
 */
- (void)invokeWithTarget:(id)target;

@end
