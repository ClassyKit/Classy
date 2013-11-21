//
//  CASRuntimeExtensionsSpec.m
//  Classy
//
//  Created by Jonas Budelmann on 15/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASRuntimeExtensions.h"
#import "XCTest+Spec.h"
#import <objc/runtime.h>

@protocol EXTRuntimeTestProtocol <NSObject>

@optional
+ (void)optionalClassMethod;
- (void)optionalInstanceMethod;

@end

@interface RuntimeTestClass : NSObject <EXTRuntimeTestProtocol>

@property (nonatomic, assign, getter = isNormalBool, readonly) BOOL normalBool;
@property (nonatomic, strong, getter = whoopsWhatArray, setter = setThatArray:) NSArray *array;
@property (copy) NSString *normalString;
@property (unsafe_unretained) id untypedObject;
@property (nonatomic, weak) NSObject *weakObject;
@property (nonatomic, assign) CGColorRef colorRef;

@end

@implementation RuntimeTestClass
@synthesize normalBool = _normalBool;
@synthesize array = m_array;
@synthesize normalString;

- (NSObject *)weakObject {
    return nil;
}

- (void)setWeakObject:(NSObject *)weakObject {
}

@dynamic untypedObject;
@end

SpecBegin(CASRuntimeExtensions)

- (void)testGetPropertyAttributesForBOOL {
    objc_property_t property = class_getProperty([RuntimeTestClass class], "normalBool");
    NSLog(@"property attributes: %s", property_getAttributes(property));

    cas_propertyAttributes *attributes = cas_copyPropertyAttributes(property);
    XCTAssertTrue(attributes != NULL, @"could not get property attributes");


    XCTAssertEqual(attributes->readonly, YES, @"");
    XCTAssertEqual(attributes->nonatomic, YES, @"");
    XCTAssertEqual(attributes->weak, NO, @"");
    XCTAssertEqual(attributes->canBeCollected, NO, @"");
    XCTAssertEqual(attributes->dynamic, NO, @"");
    XCTAssertEqual(attributes->memoryManagementPolicy, cas_propertyMemoryManagementPolicyAssign, @"");

    XCTAssertEqual(attributes->getter, @selector(isNormalBool), @"");
    XCTAssertEqual(attributes->setter, @selector(setNormalBool:), @"");

    XCTAssertTrue(strcmp(attributes->ivar, "_normalBool") == 0, @"expected property ivar name to be '_normalBool'");
    XCTAssertTrue(strlen(attributes->type) > 0, @"property type is missing from attributes");

    NSUInteger size = 0;
    NSGetSizeAndAlignment(attributes->type, &size, NULL);
    XCTAssertTrue(size > 0, @"invalid property type %s, has no size", attributes->type);

    XCTAssertNil(attributes->objectClass, @"");
    
    free(attributes);
}

- (void)testGetPropertyAttributeForStructPointer {
    objc_property_t property = class_getProperty([RuntimeTestClass class], "colorRef");
    NSLog(@"property attributes: %s", property_getAttributes(property));

    cas_propertyAttributes *attributes = cas_copyPropertyAttributes(property);
    XCTAssertTrue(attributes != NULL, @"could not get property attributes");
    XCTAssertTrue(strlen(attributes->type) > 0, @"property type is missing from attributes");
    XCTAssertNil(attributes->objectClass, @"");
}

- (void)testGetPropertyAttributesForArray {
    objc_property_t property = class_getProperty([RuntimeTestClass class], "array");
    NSLog(@"property attributes: %s", property_getAttributes(property));

    cas_propertyAttributes *attributes = cas_copyPropertyAttributes(property);
    XCTAssertTrue(attributes != NULL, @"could not get property attributes");

    XCTAssertEqual(attributes->readonly, NO, @"");
    XCTAssertEqual(attributes->nonatomic, YES, @"");
    XCTAssertEqual(attributes->weak, NO, @"");
    XCTAssertEqual(attributes->canBeCollected, NO, @"");
    XCTAssertEqual(attributes->dynamic, NO, @"");
    XCTAssertEqual(attributes->memoryManagementPolicy, cas_propertyMemoryManagementPolicyRetain, @"");

    XCTAssertEqual(attributes->getter, @selector(whoopsWhatArray), @"");
    XCTAssertEqual(attributes->setter, @selector(setThatArray:), @"");

    XCTAssertTrue(strcmp(attributes->ivar, "m_array") == 0, @"expected property ivar name to be 'm_array'");
    XCTAssertTrue(strlen(attributes->type) > 0, @"property type is missing from attributes");

    NSUInteger size = 0;
    NSGetSizeAndAlignment(attributes->type, &size, NULL);
    XCTAssertTrue(size > 0, @"invalid property type %s, has no size", attributes->type);

    XCTAssertEqualObjects(attributes->objectClass, [NSArray class], @"");

    free(attributes);
}

- (void)testGetPropertyAttributesForNormalString {
    objc_property_t property = class_getProperty([RuntimeTestClass class], "normalString");
    NSLog(@"property attributes: %s", property_getAttributes(property));

    cas_propertyAttributes *attributes = cas_copyPropertyAttributes(property);
    XCTAssertTrue(attributes != NULL, @"could not get property attributes");

    XCTAssertEqual(attributes->readonly, NO, @"");
    XCTAssertEqual(attributes->nonatomic, NO, @"");
    XCTAssertEqual(attributes->weak, NO, @"");
    XCTAssertEqual(attributes->canBeCollected, NO, @"");
    XCTAssertEqual(attributes->dynamic, NO, @"");
    XCTAssertEqual(attributes->memoryManagementPolicy, cas_propertyMemoryManagementPolicyCopy, @"");

    XCTAssertEqual(attributes->getter, @selector(normalString), @"");
    XCTAssertEqual(attributes->setter, @selector(setNormalString:), @"");

    XCTAssertTrue(strcmp(attributes->ivar, "normalString") == 0, @"expected property ivar name to match the name of the property");
    XCTAssertTrue(strlen(attributes->type) > 0, @"property type is missing from attributes");

    NSUInteger size = 0;
    NSGetSizeAndAlignment(attributes->type, &size, NULL);
    XCTAssertTrue(size > 0, @"invalid property type %s, has no size", attributes->type);

    XCTAssertEqualObjects(attributes->objectClass, [NSString class], @"");

    free(attributes);
}

- (void)testGetPropertyAttributesForUntypedObject {
    objc_property_t property = class_getProperty([RuntimeTestClass class], "untypedObject");
    NSLog(@"property attributes: %s", property_getAttributes(property));

    cas_propertyAttributes *attributes = cas_copyPropertyAttributes(property);
    XCTAssertTrue(attributes != NULL, @"could not get property attributes");

    XCTAssertEqual(attributes->readonly, NO, @"");
    XCTAssertEqual(attributes->nonatomic, NO, @"");
    XCTAssertEqual(attributes->weak, NO, @"");
    XCTAssertEqual(attributes->canBeCollected, NO, @"");
    XCTAssertEqual(attributes->dynamic, YES, @"");
    XCTAssertEqual(attributes->memoryManagementPolicy, cas_propertyMemoryManagementPolicyAssign, @"");

    XCTAssertEqual(attributes->getter, @selector(untypedObject), @"");
    XCTAssertEqual(attributes->setter, @selector(setUntypedObject:), @"");

    XCTAssertTrue(attributes->ivar == NULL, @"untypedObject property should not have a backing ivar");
    XCTAssertTrue(strlen(attributes->type) > 0, @"property type is missing from attributes");

    NSUInteger size = 0;
    NSGetSizeAndAlignment(attributes->type, &size, NULL);
    XCTAssertTrue(size > 0, @"invalid property type %s, has no size", attributes->type);

    // cannot get class for type 'id'
    XCTAssertNil(attributes->objectClass, @"");

    free(attributes);
}

- (void)testGetPropertyAttributesForWeakObject {
    objc_property_t property = class_getProperty([RuntimeTestClass class], "weakObject");
    NSLog(@"property attributes: %s", property_getAttributes(property));

    cas_propertyAttributes *attributes = cas_copyPropertyAttributes(property);
    XCTAssertTrue(attributes != NULL, @"could not get property attributes");

    XCTAssertEqual(attributes->readonly, NO, @"");
    XCTAssertEqual(attributes->nonatomic, YES, @"");
    XCTAssertEqual(attributes->weak, YES, @"");
    XCTAssertEqual(attributes->canBeCollected, NO, @"");
    XCTAssertEqual(attributes->dynamic, NO, @"");
    XCTAssertEqual(attributes->memoryManagementPolicy, cas_propertyMemoryManagementPolicyAssign, @"");

    XCTAssertEqual(attributes->getter, @selector(weakObject), @"");
    XCTAssertEqual(attributes->setter, @selector(setWeakObject:), @"");

    XCTAssertTrue(attributes->ivar == NULL, @"weakObject property should not have a backing ivar");
    XCTAssertTrue(strlen(attributes->type) > 0, @"property type is missing from attributes");

    NSUInteger size = 0;
    NSGetSizeAndAlignment(attributes->type, &size, NULL);
    XCTAssertTrue(size > 0, @"invalid property type %s, has no size", attributes->type);

    XCTAssertEqualObjects(attributes->objectClass, [NSObject class], @"");

    free(attributes);
}

SpecEnd