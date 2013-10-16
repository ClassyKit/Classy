//
//  MODArgumentDescriptorSpec.m
//  Mod
//
//  Created by Jonas Budelmann on 16/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODArgumentDescriptor.h"


struct MODStructExample {
    CGFloat dx;
    CGFloat dy;
};
typedef struct MODStructExample MODStructExample;

SpecBegin(MODArgumentDescriptor)

it(@"should return BOOL", ^{
    expect([MODArgumentDescriptor argWithObjCType:@encode(BOOL)].primitiveType).to.equal(MODPrimitiveTypeBOOL);
});

it(@"should return integer", ^{
    expect([MODArgumentDescriptor argWithObjCType:@encode(NSInteger)].primitiveType).to.equal(MODPrimitiveTypeInteger);
    expect([MODArgumentDescriptor argWithObjCType:@encode(NSUInteger)].primitiveType).to.equal(MODPrimitiveTypeInteger);
    expect([MODArgumentDescriptor argWithObjCType:@encode(int)].primitiveType).to.equal(MODPrimitiveTypeInteger);
    expect([MODArgumentDescriptor argWithObjCType:@encode(long)].primitiveType).to.equal(MODPrimitiveTypeInteger);
});

it(@"should return double", ^{
    expect([MODArgumentDescriptor argWithObjCType:@encode(double)].primitiveType).to.equal(MODPrimitiveTypeDouble);
    expect([MODArgumentDescriptor argWithObjCType:@encode(float)].primitiveType).to.equal(MODPrimitiveTypeDouble);
    expect([MODArgumentDescriptor argWithObjCType:@encode(CGFloat)].primitiveType).to.equal(MODPrimitiveTypeDouble);
});

it(@"should return CGSize", ^{
    expect([MODArgumentDescriptor argWithObjCType:@encode(CGSize)].primitiveType).to.equal(MODPrimitiveTypeCGSize);
});

it(@"should return CGRect", ^{
    expect([MODArgumentDescriptor argWithObjCType:@encode(CGRect)].primitiveType).to.equal(MODPrimitiveTypeCGRect);
});

it(@"should return UIEdgeInsets", ^{
    expect([MODArgumentDescriptor argWithObjCType:@encode(UIEdgeInsets)].primitiveType).to.equal(MODPrimitiveTypeUIEdgeInsets);
});

it(@"should return UIOffset", ^{
    expect([MODArgumentDescriptor argWithObjCType:@encode(UIOffset)].primitiveType).to.equal(MODPrimitiveTypeUIOffset);
});

it(@"should return unsupported", ^{
    expect([MODArgumentDescriptor argWithObjCType:@encode(MODStructExample)].primitiveType).to.equal(MODPrimitiveTypeUnsupported);
});

SpecEnd