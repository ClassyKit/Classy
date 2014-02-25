//
//  CASTextAttributes.h
//  
//
//  Created by Jonas Budelmann on 4/11/13.
//
//

#import <Foundation/Foundation.h>

/**
 *  Each property maps directly to a attribute name
 *  ie font = NSFontAttributeName
 */
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
@property (nonatomic, assign) CGFloat baselineOffset;

/**
 *  Transformer receiver into appropriate NSDictionary
 *
 *  @return NSDictionary containing text attribute keys and values
 */
- (NSDictionary *)dictionary;

@end
