//
//  CASStyleableItem.h
//  
//
//  Created by Jonas Budelmann on 31/10/13.
//
//

#import <Foundation/Foundation.h>

@class CASStyler;

@protocol CASStyleableItem <NSObject>

@property (nonatomic, copy) NSString *cas_styleClass;
@property (nonatomic, assign) BOOL cas_styleApplied;
@property (nonatomic, weak) id<CASStyleableItem> cas_parent;

- (void)cas_applyStyle:(CASStyler *)styler;

@end
