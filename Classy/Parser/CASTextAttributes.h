//
//  CASTextAttributes.h
//  
//
//  Created by Jonas Budelmann on 4/11/13.
//
//

#import <Foundation/Foundation.h>

@interface CASTextAttributes : NSObject

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) NSMutableParagraphStyle *paragraphStyle;
@property (nonatomic, strong) UIColor *foregroundColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) NSInteger ligature;
@property (nonatomic, assign) CGFloat kern;
@property (nonatomic, assign) NSUnderlineStyle strikethroughStyle;
@property (nonatomic, assign) NSUnderlineStyle underlineStyle;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, strong) NSShadow *shadow;

// TODO support relevant iOS 7 properties

- (NSDictionary *)dictionary;

@end
