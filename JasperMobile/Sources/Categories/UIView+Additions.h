/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @author Oleksandr Dahno odahno@tibco.com
 @since 1.9
 */

#import <UIKit/UIKit.h>

@interface UIView (Additions)

- (UIColor *) colorOfPoint:(CGPoint)point;

- (UIImage *)renderedImageForView:(UIView *)view;
- (UIImage *)renderedImage;

- (void)updateFrameWithOrigin:(CGPoint)newOrigin size:(CGSize)newSize;
- (void)updateOriginWithOrigin:(CGPoint)newOrigin;
- (void)updateOriginXWithValue:(CGFloat)newOriginX;
- (void)updateOriginYWithValue:(CGFloat)newOriginY;
- (void)updateHeightWithValue:(CGFloat)newHeight;

// Autolayout
// Make subview fill its parent view
- (void)fillWithView:(UIView *)view;
@end
