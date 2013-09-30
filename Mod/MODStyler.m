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

/**
 *  Returns a integer representation of how relevant this selector is for the view
 *  Provides a way to order selectors.
 *
 *  @return Precendence score, `0` means dont apply this selector
 */
- (NSUInteger)precedenceForStyleSelector:(MODStyleSelector *)selector withView:(UIView *)view;

@end

@implementation MODStyler

- (id)initWithFilePath:(NSString *)filePath error:(NSError **)error {
    self = [super init];
    if (!self) return nil;

    self.styles = [MODParser stylesFromFilePath:filePath error:error];
    self.viewClassInfoCache = NSMapTable.strongToStrongObjectsMapTable;

    return self;
}

- (void)styleView:(UIView *)view {
    //TODO get all selectors that apply to this view.
    //TODO order ascending by precedence

    //unordered dumb version. doesn't check styleClass
    for (MODStyleSelector *selector in self.styles) {
        if ([view isKindOfClass:selector.viewClass]) {
            
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

- (NSUInteger)precedenceForStyleSelector:(MODStyleSelector *)selector withView:(UIView *)view {
    return 0;
}

@end
