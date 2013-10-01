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

@property (nonatomic, strong) NSArray *styles;
@property (nonatomic, strong) NSMapTable *viewClassInfoCache;

@end

@implementation MODStyler

- (id)initWithFilePath:(NSString *)filePath error:(NSError **)error {
    self = [super init];
    if (!self) return nil;

    //TODO order ascending by precedence
    self.styles = [MODParser stylesFromFilePath:filePath error:error];
    self.viewClassInfoCache = NSMapTable.strongToStrongObjectsMapTable;

    return self;
}

- (void)styleView:(UIView *)view {
    //TODO get all selectors that apply to this view.
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
