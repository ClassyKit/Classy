//
//  CASArgumentDescriptorSpec.m
//  Classy
//
//  Created by Jonas Budelmann on 16/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASArgumentDescriptor.h"

struct CASStructExample {
    CGFloat dx;
    CGFloat dy;
};
typedef struct CASStructExample CASStructExample;

SpecBegin(CASArgumentDescriptor)

it(should_return_BOOL, ^{
    expect([CASArgumentDescriptor argWithObjCType:@encode(BOOL)].primitiveType).to.equal(CASPrimitiveTypeBOOL);
})

it(should_return_integer, ^{
    expect([CASArgumentDescriptor argWithObjCType:@encode(NSInteger)].primitiveType).to.equal(CASPrimitiveTypeInteger);
    expect([CASArgumentDescriptor argWithObjCType:@encode(NSUInteger)].primitiveType).to.equal(CASPrimitiveTypeInteger);
    expect([CASArgumentDescriptor argWithObjCType:@encode(int)].primitiveType).to.equal(CASPrimitiveTypeInteger);
    expect([CASArgumentDescriptor argWithObjCType:@encode(long)].primitiveType).to.equal(CASPrimitiveTypeInteger);
})

it(should_return_double, ^{
    expect([CASArgumentDescriptor argWithObjCType:@encode(double)].primitiveType).to.equal(CASPrimitiveTypeDouble);
    expect([CASArgumentDescriptor argWithObjCType:@encode(float)].primitiveType).to.equal(CASPrimitiveTypeDouble);
    expect([CASArgumentDescriptor argWithObjCType:@encode(CGFloat)].primitiveType).to.equal(CASPrimitiveTypeDouble);
})

it(should_return_CGSize, ^{
    expect([CASArgumentDescriptor argWithObjCType:@encode(CGSize)].primitiveType).to.equal(CASPrimitiveTypeCGSize);
})

it(should_return_CGRect, ^{
    expect([CASArgumentDescriptor argWithObjCType:@encode(CGRect)].primitiveType).to.equal(CASPrimitiveTypeCGRect);
})

it(should_return_UIEdgeInsets, ^{
    expect([CASArgumentDescriptor argWithObjCType:@encode(UIEdgeInsets)].primitiveType).to.equal(CASPrimitiveTypeUIEdgeInsets);
})

it(should_return_UIOffset, ^{
    expect([CASArgumentDescriptor argWithObjCType:@encode(UIOffset)].primitiveType).to.equal(CASPrimitiveTypeUIOffset);
})

it(should_return_unsupported, ^{
    expect([CASArgumentDescriptor argWithObjCType:@encode(CASStructExample)].primitiveType).to.equal(CASPrimitiveTypeUnsupported);
})

SpecEnd