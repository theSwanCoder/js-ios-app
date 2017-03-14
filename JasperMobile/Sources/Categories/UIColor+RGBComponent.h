/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

#import <UIKit/UIKit.h>

@interface UIColor (RGBComponent)

/**
 Returns an rgb color component as normalized value required by colorWithRed:green:blue:alpha: method
 */
+ (CGFloat)rgbComponent:(CGFloat)color;

/**
 Returns an color from hex string. Assumes input like "#00FF00" (#RRGGBB).
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString;

+ (UIColor *)colorWithRedComponent:(CGFloat)redComponent greenComponent:(CGFloat)greenComponent blueComponent:(CGFloat)blueComponent;

+ (UIColor *)сolorFromColor:(UIColor *)color differents:(CGFloat)differents increase:(BOOL)increase;

@end
