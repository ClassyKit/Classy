//
//  UIBarItem+CASAdditions.h
//  
//
//  Created by Jonas Budelmann on 5/11/13.
//
//

#import <UIKit/UIKit.h>
#import "CASStyleableItem.h"

@interface UIBarItem (CASAdditions) <CASStyleableItem>

@property (nonatomic, weak, readwrite) id<CASStyleableItem> cas_parent;

@end
