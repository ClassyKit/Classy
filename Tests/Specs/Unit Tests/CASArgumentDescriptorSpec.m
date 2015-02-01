//
//  CASArgumentDescriptorSpec.m
//  Classy
//
//  Created by Jonas Budelmann on 16/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASArgumentDescriptor.h"
#import "XCTest+Spec.h"

struct CASStructExample {
    CGFloat dx;
    CGFloat dy;
};
typedef struct CASStructExample CASStructExample;

SpecBegin(CASArgumentDescriptor)

- (void)testReturnBOOL {
    expect([CASArgumentDescriptor argWithObjCType:@encode(BOOL)].primitiveType).to.equal(CASPrimitiveTypeBOOL);
}

- (void)testReturnInteger {
    expect([CASArgumentDescriptor argWithObjCType:@encode(NSInteger)].primitiveType).to.equal(CASPrimitiveTypeInteger);
    expect([CASArgumentDescriptor argWithObjCType:@encode(NSUInteger)].primitiveType).to.equal(CASPrimitiveTypeInteger);
    expect([CASArgumentDescriptor argWithObjCType:@encode(int)].primitiveType).to.equal(CASPrimitiveTypeInteger);
    expect([CASArgumentDescriptor argWithObjCType:@encode(long)].primitiveType).to.equal(CASPrimitiveTypeInteger);
}

- (void)testReturnDouble {
    expect([CASArgumentDescriptor argWithObjCType:@encode(double)].primitiveType).to.equal(CASPrimitiveTypeDouble);
    expect([CASArgumentDescriptor argWithObjCType:@encode(float)].primitiveType).to.equal(CASPrimitiveTypeFloat);
    if (sizeof(void*) == 4) {
        expect([CASArgumentDescriptor argWithObjCType:@encode(CGFloat)].primitiveType).to.equal(CASPrimitiveTypeFloat);
    } else if (sizeof(void*) == 8) {
        expect([CASArgumentDescriptor argWithObjCType:@encode(CGFloat)].primitiveType).to.equal(CASPrimitiveTypeDouble);
    }
}

- (void)testReturnCGSize {
    expect([CASArgumentDescriptor argWithObjCType:@encode(CGSize)].primitiveType).to.equal(CASPrimitiveTypeCGSize);
}

- (void)testReturnCGRect {
    expect([CASArgumentDescriptor argWithObjCType:@encode(CGRect)].primitiveType).to.equal(CASPrimitiveTypeCGRect);
}

- (void)testReturnCGPoint {
    expect([CASArgumentDescriptor argWithObjCType:@encode(CGPoint)].primitiveType).to.equal(CASPrimitiveTypeCGPoint);
}

- (void)testReturnUIEdgeInsets {
    expect([CASArgumentDescriptor argWithObjCType:@encode(UIEdgeInsets)].primitiveType).to.equal(CASPrimitiveTypeUIEdgeInsets);
}

- (void)testReturnUIOffset {
    expect([CASArgumentDescriptor argWithObjCType:@encode(UIOffset)].primitiveType).to.equal(CASPrimitiveTypeUIOffset);
}

- (void)testReturnUnsupported {
    expect([CASArgumentDescriptor argWithObjCType:@encode(CASStructExample)].primitiveType).to.equal(CASPrimitiveTypeUnsupported);
}

- (void)testReturnCGColorRef {
    expect([CASArgumentDescriptor argWithObjCType:@encode(CGColorRef)].primitiveType).to.equal(CASPrimitiveTypeCGColorRef);

}

SpecEnd