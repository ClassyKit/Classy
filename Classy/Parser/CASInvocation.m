//
//  CASInvocation.m
//  
//
//  Created by Jonas Budelmann on 5/11/13.
//
//

#import "CASInvocation.h"

@interface CASInvocation ()

@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, strong) NSInvocation *invocation;

@end

@implementation CASInvocation

- (id)initWithInvocation:(NSInvocation *)invocation forKeyPath:(NSString *)keyPath {
    self = [super init];
    if (!self) return nil;

    self.invocation = invocation;
    self.keyPath = keyPath;

    return self;
}

- (void)invokeWithTarget:(id)target {
    id resolvedTarget = self.keyPath ? [target valueForKeyPath:self.keyPath] : target;
    [self.invocation invokeWithTarget:resolvedTarget];
}

@end
