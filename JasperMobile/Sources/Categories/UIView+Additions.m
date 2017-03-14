/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "UIView+Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Additions)
- (UIColor *) colorOfPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    return color;
}

- (UIImage *)renderedImageForView:(UIView *)view
{
    CGRect rect = [view bounds];
    CGSize size = [view bounds].size;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIImage *image;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);

    BOOL result = [view drawViewHierarchyInRect:rect afterScreenUpdates:YES];
    if (!result) {
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)renderedImage
{
    return [self renderedImageForView:self];
}

- (void)updateFrameWithOrigin:(CGPoint)newOrigin size:(CGSize)newSize {
    CGRect viewFrame = self.frame;
    viewFrame.origin = newOrigin;
    viewFrame.size = newSize;
    self.frame = viewFrame;
}

- (void)updateOriginWithOrigin:(CGPoint)newOrigin {
    CGRect viewFrame = self.frame;
    viewFrame.origin = newOrigin;
    self.frame = viewFrame;
//    self.frame = CGRectIntegral(viewFrame);
}

- (void)updateOriginXWithValue:(CGFloat)newOriginX {
    CGRect viewFrame = self.frame;
    viewFrame.origin.x = newOriginX;
    self.frame = viewFrame;
//    self.frame = CGRectIntegral(viewFrame);
}

- (void)updateOriginYWithValue:(CGFloat)newOriginY {
    CGRect viewFrame = self.frame;
    viewFrame.origin.y = newOriginY;
    self.frame = viewFrame;
//    self.frame = CGRectIntegral(viewFrame);
}

- (void)updateHeightWithValue:(CGFloat)newHeight {
    CGRect viewFrame = self.frame;
    viewFrame.size.height = newHeight;
    self.frame = viewFrame;
//    self.frame = CGRectIntegral(viewFrame);
}

#pragma mark - Autolayout

- (void)fillWithView:(UIView *)view
{
    [self addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[nestedView]-0-|"
                                                                 options:NSLayoutFormatAlignAllLeading
                                                                 metrics:nil
                                                                   views:@{@"nestedView": view}]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[nestedView]-0-|"
                                                                 options:NSLayoutFormatAlignAllLeading
                                                                 metrics:nil
                                                                   views:@{@"nestedView": view}]];
}


@end
