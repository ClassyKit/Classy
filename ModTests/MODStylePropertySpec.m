//
//  MODStylePropertySpec.m
//  Mod
//
//  Created by Jonas Budelmann on 16/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODStyleProperty.h"

SpecBegin(MODStyleProperty)

it(@"should not parse 0 units", ^{
    NSArray *valueTokens = @[
        [MODToken tokenOfType:MODTokenTypeRef value:@3],
    ];

    MODStyleProperty *prop = [[MODStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    __block CGSize size = CGSizeZero;
    expect([prop transformValuesToCGSize:&size]).to.beFalsy();
    expect(size).to.equal(CGSizeZero);

    __block UIEdgeInsets insets = UIEdgeInsetsZero;
    expect([prop transformValuesToUIEdgeInsets:&insets]).to.beFalsy();
    expect(insets).to.equal(UIEdgeInsetsZero);
});

it(@"should parse 1 unit", ^{
    NSArray *valueTokens = @[
        [MODToken tokenOfType:MODTokenTypeUnit value:@3],
    ];

    MODStyleProperty *prop = [[MODStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    __block CGSize size = CGSizeZero;
    expect([prop transformValuesToCGSize:&size]).to.beTruthy();
    expect(size).to.equal(CGSizeMake(3, 3));

    __block UIEdgeInsets insets = UIEdgeInsetsZero;
    expect([prop transformValuesToUIEdgeInsets:&insets]).to.beTruthy();
    expect(insets).to.equal(UIEdgeInsetsMake(3, 3, 3, 3));
});

it(@"should parse 2 units", ^{
    NSArray *valueTokens = @[
        [MODToken tokenOfType:MODTokenTypeUnit value:@3],
        [MODToken tokenOfType:MODTokenTypeUnit value:@34],
    ];

    MODStyleProperty *prop = [[MODStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    __block CGSize size = CGSizeZero;
    expect([prop transformValuesToCGSize:&size]).to.beTruthy();
    expect(size).to.equal(CGSizeMake(3, 34));

    __block UIEdgeInsets insets = UIEdgeInsetsZero;
    expect([prop transformValuesToUIEdgeInsets:&insets]).to.beTruthy();
    expect(insets).to.equal(UIEdgeInsetsMake(34, 3, 34, 3));
});

it(@"should resolve simple expression", ^{
    NSArray *valueTokens = @[
        [MODToken tokenOfType:MODTokenTypeUnit value:@3],
        [MODToken tokenOfType:MODTokenTypeOperator value:@"*"],
        [MODToken tokenOfType:MODTokenTypeUnit value:@2],
        [MODToken tokenOfType:MODTokenTypeOperator value:@"+"],
        [MODToken tokenOfType:MODTokenTypeUnit value:@5],
    ];

    MODStyleProperty *prop = [[MODStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"3*2+5");
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"11");
});

it(@"should resolve expression with function", ^{
    NSArray *valueTokens = @[
        [MODToken tokenOfType:MODTokenTypeRef value:@"floor"],
        [MODToken tokenOfType:MODTokenTypeSpace value:@"  "],
        [MODToken tokenOfType:MODTokenTypeLeftRoundBrace value:@"("],
        [MODToken tokenOfType:MODTokenTypeUnit value:@4.5],
        [MODToken tokenOfType:MODTokenTypeRightRoundBrace value:@")"],
        [MODToken tokenOfType:MODTokenTypeOperator value:@"*"],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeUnit value:@2],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeOperator value:@"+"],
        [MODToken tokenOfType:MODTokenTypeUnit value:@5],
    ];

    MODStyleProperty *prop = [[MODStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"floor  (4.5)* 2 +5");
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"13");
});

it(@"should resolve 2-tuple", ^{
    NSArray *valueTokens = @[
        [MODToken tokenOfType:MODTokenTypeLeftRoundBrace value:@"("],
        [MODToken tokenOfType:MODTokenTypeUnit value:@4.5],
        [MODToken tokenOfType:MODTokenTypeOperator value:@","],
        [MODToken tokenOfType:MODTokenTypeUnit value:@2],
        [MODToken tokenOfType:MODTokenTypeRightRoundBrace value:@")"],
        [MODToken tokenOfType:MODTokenTypeOperator value:@"*"],
        [MODToken tokenOfType:MODTokenTypeUnit value:@5],
    ];

    MODStyleProperty *prop = [[MODStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"(4.5,2)*5");
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"(22.5,10)");
});

it(@"should resolve 4-tuple", ^{
    NSArray *valueTokens = @[
        [MODToken tokenOfType:MODTokenTypeLeftRoundBrace value:@"("],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeUnit value:@6],
        [MODToken tokenOfType:MODTokenTypeOperator value:@","],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeUnit value:@10],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeUnit value:@12],
        [MODToken tokenOfType:MODTokenTypeOperator value:@","],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeUnit value:@8],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeRightRoundBrace value:@")"],
        [MODToken tokenOfType:MODTokenTypeOperator value:@" / "],
        [MODToken tokenOfType:MODTokenTypeUnit value:@2],
    ];

    MODStyleProperty *prop = [[MODStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"( 6, 10 12, 8 ) / 2");
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"(3, 5,6, 4)");
});

it(@"should solve mixed expression", ^{
    NSArray *valueTokens = @[
        [MODToken tokenOfType:MODTokenTypeRef value:@"tiger"],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeSelector value:@"place"],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeUnit value:@2],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeOperator value:@"+"],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeUnit value:@2],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeLeftRoundBrace value:@"("],
        [MODToken tokenOfType:MODTokenTypeUnit value:@1],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeOperator value:@"+"],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeLeftRoundBrace value:@"("],
        [MODToken tokenOfType:MODTokenTypeUnit value:@2],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeOperator value:@"*"],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeUnit value:@3],
        [MODToken tokenOfType:MODTokenTypeRightRoundBrace value:@")"],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeUnit value:@3],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeOperator value:@"+"],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeUnit value:@0.5],
        [MODToken tokenOfType:MODTokenTypeRightRoundBrace value:@")"],
        [MODToken tokenOfType:MODTokenTypeOperator value:@" *"],
        [MODToken tokenOfType:MODTokenTypeSpace value:@" "],
        [MODToken tokenOfType:MODTokenTypeUnit value:@2],
        [MODToken tokenOfType:MODTokenTypeOperator value:@" / "],
        [MODToken tokenOfType:MODTokenTypeUnit value:@5],
    ];

    MODStyleProperty *prop = [[MODStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"tiger place 2 + 2 (1 + (2 * 3) 3 + 0.5) * 2 / 5");
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"tiger place 4(2,1.4) ");
});

SpecEnd