//
//  MODStyler.m
//  Mod
//
//  Created by Jonas Budelmann on 16/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MODStyler.h"
#import "MODParser.h"
#import "MODStyleSelector.h"
#import "MODViewClassInfo.h"

@interface MODStyler ()

@property (nonatomic, strong) NSMutableArray *styles;
@property (nonatomic, strong) NSMapTable *viewClassInfoCache;
@property (nonatomic, strong) NSDictionary *keyPathsByStyleName;

@end

@implementation MODStyler

- (id)initWithFilePath:(NSString *)filePath error:(NSError **)error {
    self = [super init];
    if (!self) return nil;

    self.styles = [[MODParser stylesFromFilePath:filePath error:error] mutableCopy];

    //order descending by precedence
    [self.styles sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(MODStyleSelector *s1, MODStyleSelector *s2) {
        if (s1.precedence == s2.precedence) return NSOrderedSame;
        if (s1.precedence <  s2.precedence) return NSOrderedDescending;
        return NSOrderedAscending;
    }];

    self.viewClassInfoCache = NSMapTable.strongToStrongObjectsMapTable;

    self.keyPathsByStyleName = @{
        @"borderColor" : @"layer.borderColor",
        @"borderWidth" : @"layer.borderWidth",
        @"borderRadius" : @"layer.cornerRadius"
    };

    return self;
}

- (void)styleView:(UIView *)view {
    //TODO style lookup table to improve speed.

    for (MODStyleSelector *styleSelector in self.styles.reverseObjectEnumerator) {
        if ([styleSelector shouldSelectView:view]) {
            //apply style nodes
            for (MODStyleProperty *styleProperty in styleSelector.node.properties) {
                //TODO type checking and catch errors
                NSString *keyPath = self.keyPathsByStyleName[styleProperty.name] ?:styleProperty.name;
                id value = [styleProperty.values lastObject];

                //TODO smarter more automatic way of coercing types
                //[MODValueTransformers transformValue:value toType:@encode(CGColorRef)];
                if ([keyPath isEqualToString:@"layer.borderColor"]) {
                    value = (id)[value CGColor];
                }

                [view setValue:value forKeyPath:keyPath];

            }
        }
    }
}

- (MODViewClassInfo *)viewClassInfoForClass:(Class)class {
    MODViewClassInfo *classInfo = [self.viewClassInfoCache objectForKey:class];
    if (!classInfo) {
        classInfo = MODViewClassInfo.new;
        [self.viewClassInfoCache setObject:classInfo forKey:class];
    }
    return classInfo;
}

@end
