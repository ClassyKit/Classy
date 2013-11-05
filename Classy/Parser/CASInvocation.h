//
//  CASInvocation.h
//  
//
//  Created by Jonas Budelmann on 5/11/13.
//
//

#import <Foundation/Foundation.h>

@interface CASInvocation : NSObject

- (id)initWithInvocation:(NSInvocation *)invocation forKeyPath:(NSString *)keyPath;

- (void)invokeWithTarget:(id)target;

@end
