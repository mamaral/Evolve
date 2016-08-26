//
//  UIColor+Utils.h
//  Evolve
//
//  Created by Mike on 8/26/16.
//  Copyright © 2016 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utils)

+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (UIColor *)randomColor;

- (CGFloat)distanceFromColor:(UIColor *)color;

@end
