/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

#import <UIKit/UIKit.h>

@interface UIImage (Additions)
+(UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor;

- (UIImage *)colorizeImageWithColor:(id)theColor;

- (UIImage *)cropedImageForRect:(CGRect)rect;

@end
