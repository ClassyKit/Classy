//
//  CASPropertyDescriptor.m
//  Classy
//
//  Created by Jonas Budelmann on 12/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASPropertyDescriptor.h"
#import "NSString+CASAdditions.h"

@interface CASPropertyDescriptor ()

@property (nonatomic, strong, readwrite) NSString *key;
@property (nonatomic, strong, readwrite) NSArray *argumentDescriptors;
@property (nonatomic, assign, readwrite) SEL setter;

@end

@implementation CASPropertyDescriptor

- (id)initWithKey:(NSString *)key argumentDescriptors:(NSArray *)argumentDescriptors {
    self = [super init];
    if (!self) return nil;

    self.key = key;
    self.argumentDescriptors = argumentDescriptors;
    NSString *setterString = [NSString stringWithFormat:@"set%@:", [key cas_stringByCapitalizingFirstLetter]];
    self.setter = NSSelectorFromString(setterString);

    return self;
}

- (id)initWithKey:(NSString *)key argumentDescriptors:(NSArray *)argumentDescriptors setter:(SEL)setter {
    self = [super init];
    if (!self) return nil;

    self.key = key;
    self.argumentDescriptors = argumentDescriptors;
    self.setter = setter;
    
    return self;
}

@end
