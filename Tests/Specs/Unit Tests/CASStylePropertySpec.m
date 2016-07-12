//
//  CASStylePropertySpec.m
//  Classy
//
//  Created by Jonas Budelmann on 16/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASStyleProperty.h"
#import "XCTest+Spec.h"
#import "CASLexer.h"

NSArray *CASTokensFromString(NSString *string) {
    NSMutableArray *tokens = NSMutableArray.new;
    CASLexer *lexer = [[CASLexer alloc] initWithString:string];
    while (lexer.peekToken && lexer.peekToken.type != CASTokenTypeEOS) {
        [tokens addObject:lexer.nextToken];
    }
    return tokens;
}

SpecBegin(CASStyleProperty)

- (void)testNotParseZeroUnits {
    NSArray *valueTokens = @[
        [CASToken tokenOfType:CASTokenTypeRef value:@3],
    ];

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    __block CGSize size = CGSizeZero;
    expect([prop transformValuesToCGSize:&size]).to.beFalsy();
    expect(size).to.equal(CGSizeZero);

    __block UIEdgeInsets insets = UIEdgeInsetsZero;
    expect([prop transformValuesToUIEdgeInsets:&insets]).to.beFalsy();
    expect(insets).to.equal(UIEdgeInsetsZero);

    __block CGRect rect = CGRectZero;
    expect([prop transformValuesToCGRect:&rect]).to.beFalsy();
    expect(rect).to.equal(CGRectZero);

    __block CGPoint point = CGPointZero;
    expect([prop transformValuesToCGPoint:&point]).to.beFalsy();
    expect(point).to.equal(CGPointZero);
}


- (void)testParseOneUnit {
    NSArray *valueTokens = CASTokensFromString(@"3");

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    __block CGSize size = CGSizeZero;
    expect([prop transformValuesToCGSize:&size]).to.beTruthy();
    expect(size).to.equal(CGSizeMake(3, 3));

    __block UIEdgeInsets insets = UIEdgeInsetsZero;
    expect([prop transformValuesToUIEdgeInsets:&insets]).to.beTruthy();
    expect(insets).to.equal(UIEdgeInsetsMake(3, 3, 3, 3));

    __block CGRect rect = CGRectZero;
    expect([prop transformValuesToCGRect:&rect]).to.beFalsy();
    expect(rect).to.equal(CGRectZero);

    __block CGPoint point = CGPointZero;
    expect([prop transformValuesToCGPoint:&point]).to.beTruthy();
    expect(point).to.equal(CGPointMake(3, 3));
}

- (void)testParseTwoUnits {
    NSArray *valueTokens = CASTokensFromString(@"3 34");

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    __block CGSize size = CGSizeZero;
    expect([prop transformValuesToCGSize:&size]).to.beTruthy();
    expect(size).to.equal(CGSizeMake(3, 34));

    __block UIEdgeInsets insets = UIEdgeInsetsZero;
    expect([prop transformValuesToUIEdgeInsets:&insets]).to.beTruthy();
    expect(insets).to.equal(UIEdgeInsetsMake(3, 34, 3, 34));

    __block CGRect rect = CGRectZero;
    expect([prop transformValuesToCGRect:&rect]).to.beFalsy();
    expect(rect).to.equal(CGRectZero);

    __block CGPoint point = CGPointZero;
    expect([prop transformValuesToCGPoint:&point]).to.beTruthy();
    expect(point).to.equal(CGPointMake(3, 34));
}


- (void)testParseFourUnits {
    NSArray *valueTokens = CASTokensFromString(@"1, 2, 3, 4");

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    __block CGSize size = CGSizeZero;
    expect([prop transformValuesToCGSize:&size]).to.beFalsy();
    expect(size).to.equal(CGSizeZero);

    __block UIEdgeInsets insets = UIEdgeInsetsZero;
    expect([prop transformValuesToUIEdgeInsets:&insets]).to.beTruthy();
    expect(insets).to.equal(UIEdgeInsetsMake(1, 2, 3, 4));

    __block CGRect rect = CGRectZero;
    expect([prop transformValuesToCGRect:&rect]).to.beTruthy();
    expect(rect).to.equal(CGRectMake(1, 2, 3, 4));

    __block CGPoint point = CGPointZero;
    expect([prop transformValuesToCGPoint:&point]).to.beFalsy();
    expect(point).to.equal(CGPointZero);
}

- (void)testNamedColor {
    NSArray *valueTokens = CASTokensFromString(@"red");

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    UIColor *color = nil;
    [prop transformValuesToUIColor:&color];
    expect(color).to.equal([UIColor redColor]);
}

- (void)testWellFormedRGBColor {
    NSArray *valueTokens = CASTokensFromString(@"rgb(245, 215, 200)");

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    UIColor *color = nil;
    [prop transformValuesToUIColor:&color];
    expect(color).to.equal([UIColor colorWithRed:245/255.0 green:215/255.0 blue:200/255.0 alpha:1]);
}

- (void)testWellFormedRGBAColor {
    NSArray *valueTokens = CASTokensFromString(@"rgba(200, 215, 200, 0.5)");

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    UIColor *color = nil;
    [prop transformValuesToUIColor:&color];
    expect(color).to.equal([UIColor colorWithRed:200/255.0 green:215/255.0 blue:200/255.0 alpha:0.5]);
}

- (void)testMalformedFormedRGBAColor {
    NSArray *valueTokens = CASTokensFromString(@"rgba( 10 , 215   , 200   , 0.5  )");

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    UIColor *color = nil;
    [prop transformValuesToUIColor:&color];
    expect(color).to.equal([UIColor colorWithRed:10/255.0 green:215/255.0 blue:200/255.0 alpha:0.5]);
}

- (void)testRGBAWithoutBracesColor {
    NSArray *valueTokens = CASTokensFromString(@"rgba 10.1 215 200 0.5");

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    UIColor *color = nil;
    [prop transformValuesToUIColor:&color];
    expect(color).to.equal([UIColor colorWithRed:10.1/255.0 green:215/255.0 blue:200/255.0 alpha:0.5]);
}

- (void)testWellFormedHSLColor {
    NSArray *valueTokens = CASTokensFromString(@"hsl(200, 60%, 100%)");
    
    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    
    UIColor *color = nil;
    [prop transformValuesToUIColor:&color];
    expect(color).to.equal([UIColor colorWithHue:200.0/360.0 saturation:60.0/100.0 brightness:100.0/100.0 alpha:1.0]);
}

- (void)testWellFormedHSLAColor {
    NSArray *valueTokens = CASTokensFromString(@"hsla(200, 60%, 100%, 0.5)");
    
    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    
    UIColor *color = nil;
    [prop transformValuesToUIColor:&color];
    expect(color).to.equal([UIColor colorWithHue:200.0/360.0 saturation:60.0/100.0 brightness:100.0/100.0 alpha:0.5]);
}

- (void)testMalformedFormedHSLAColor {
    NSArray *valueTokens = CASTokensFromString(@"hsla( 200 , 60%   , 100%   , 0.5  )");
    
    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    
    UIColor *color = nil;
    [prop transformValuesToUIColor:&color];
    expect(color).to.equal([UIColor colorWithHue:200.0/360.0 saturation:60.0/100.0 brightness:100.0/100.0 alpha:0.5]);
}

- (void)testHSLAWithoutBracesColor {
    NSArray *valueTokens = CASTokensFromString(@"hsla 200 60% 100% 0.5");
    
    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    
    UIColor *color = nil;
    [prop transformValuesToUIColor:&color];
    expect(color).to.equal([UIColor colorWithHue:200.0/360.0 saturation:60.0/100.0 brightness:100.0/100.0 alpha:0.5]);
}

- (void)testResolveSimpleExpression {
    NSArray *valueTokens = CASTokensFromString(@"3 * 2 + 5");

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"11");
}

- (void)testResolveExpressionWithFunction {
    NSArray *valueTokens = CASTokensFromString(@"floor  (4.5)* 2 +5");

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"13");
}

- (void)testResolveTwoTuple {
    NSArray *valueTokens = CASTokensFromString(@"(4.5,2)*5");

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"(22.5,10)");
}

- (void)testResolveTwoTupleForwards {
    NSArray *valueTokens = CASTokensFromString(@"5*(4.5,2)");

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"(22.5,10)");
}

- (void)testResolveQuadTuple {
    NSArray *valueTokens = CASTokensFromString(@"( 6, 10 12, 8 ) / 2");

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"(3,5,6,4)");
}

- (void)testSolveMixedExpression {
    NSArray *valueTokens = CASTokensFromString(@"tiger place 2 + 2 (1 + (2 * 3) 3 + 0.5) * 2 / 5");

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"tiger place 4(2,1.4)");
}

- (void)testImageFromMainBundle {
    NSArray *valueTokens = CASTokensFromString(@"test_image_1");
    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    __block UIImage *image = nil;
    expect([prop transformValuesToUIImage:&image]).to.beTruthy();
    expect(image).toNot.beNil();
}

- (void)testImageFromDocumentsDirectory {
    
    // First put the image in the documents directory
    NSString *imageBundlePath = [[NSBundle mainBundle] pathForResource:@"test_image_2" ofType:@"png"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths firstObject];
    [[NSFileManager defaultManager] copyItemAtPath:imageBundlePath toPath:[docsPath stringByAppendingPathComponent:@"test_image_2.png"] error:nil];
    
    // Test with no extension
    NSArray *valueTokens = CASTokensFromString(@"'documents://test_image_2.png'");
    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    
    __block UIImage *image = nil;
    expect([prop transformValuesToUIImage:&image]).to.beTruthy();
    expect(image).toNot.beNil();
}

- (void)testImageFromDocumentsDirectoryWithComplexPath {
    
    // First put the image in the documents directory
    NSString *imageBundlePath = [[NSBundle mainBundle] pathForResource:@"test_image_2" ofType:@"png"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [[paths firstObject] stringByAppendingPathComponent:@"test/extra"];
    [[NSFileManager defaultManager] createDirectoryAtPath:docsPath withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:imageBundlePath toPath:[docsPath stringByAppendingPathComponent:@"test_image_2.png"] error:nil];
    
    // Test with no extension
    NSArray *valueTokens = CASTokensFromString(@"'documents:///test/extra/test_image_2.png'");
    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    
    __block UIImage *image = nil;
    expect([prop transformValuesToUIImage:&image]).to.beTruthy();
    expect(image).toNot.beNil();
}

- (void)testImageFromCachesDirectory {
    // First put the image in the documents directory
    NSString *imageBundlePath = [[NSBundle mainBundle] pathForResource:@"test_image_3" ofType:@"png"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths firstObject];
    [[NSFileManager defaultManager] createDirectoryAtPath:docsPath withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:imageBundlePath toPath:[docsPath stringByAppendingPathComponent:@"test_image_3.png"] error:nil];
    
    // Test with no extension
    NSArray *valueTokens = CASTokensFromString(@"'caches://test_image_3.png'");
    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    
    __block UIImage *image = nil;
    expect([prop transformValuesToUIImage:&image]).to.beTruthy();
    expect(image).toNot.beNil();
}

- (void)testFont {
    NSArray *valueTokens = CASTokensFromString(@"\"Palatino\" 24");
    
    CASStyleProperty *prop = [[CASStyleProperty alloc]initWithNameToken:nil valueTokens:valueTokens];
    __block UIFont *font = nil;
    expect([prop transformValuesToUIFont:&font]).to.beTruthy();
    expect(font.familyName).to.equal(@"Palatino");
    expect(font.pointSize).to.equal(24.0f);
}

- (void)testSystemFont {
    NSArray *valueTokens = CASTokensFromString(@"System 12");
    
    CASStyleProperty *prop = [[CASStyleProperty alloc]initWithNameToken:nil valueTokens:valueTokens];
    __block UIFont *font = nil;
    expect([prop transformValuesToUIFont:&font]).to.beTruthy();
    expect(font.familyName).to.equal([UIFont systemFontOfSize:12].familyName);
    expect(font.pointSize).to.equal(12);
}

- (void)testSystemFontWeight {
    NSArray *valueTokens = CASTokensFromString(@"System-Medium 18");
    
    CASStyleProperty *prop = [[CASStyleProperty alloc]initWithNameToken:nil valueTokens:valueTokens];
    __block UIFont *font = nil;
    expect([prop transformValuesToUIFont:&font]).to.beTruthy();
    expect([font.fontDescriptor.fontAttributes[UIFontDescriptorNameAttribute] rangeOfString:@"Medium"].location != NSNotFound).to.beTruthy();
    expect(font.pointSize).to.equal(18);
}

- (void)testPreferredFontForTextStyle {
    NSArray *valueTokens = CASTokensFromString(@"body");
    
    CASStyleProperty *prop = [[CASStyleProperty alloc]initWithNameToken:nil valueTokens:valueTokens];
    __block UIFont *font = nil;
    if ([UIFont respondsToSelector:@selector(preferredFontForTextStyle:)]) {
        expect([prop transformValuesToUIFont:&font]).to.beTruthy();
        expect(font).to.equal([UIFont preferredFontForTextStyle:@"UICTFontTextStyleBody"]);
    } else {
        expect([prop transformValuesToUIFont:&font]).to.beFalsy();
    }
}

SpecEnd
