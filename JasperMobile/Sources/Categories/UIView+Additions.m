/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
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
//    [self updateOriginWithOrigin:newOrigin];
//    [self updateSizeWithSize:newSize];
    CGRect viewFrame = self.frame;
    viewFrame.origin = newOrigin;
    viewFrame.size = newSize;
    self.frame = CGRectIntegral(viewFrame);
}

- (void)updateOriginWithOrigin:(CGPoint)newOrigin {
//    [self updateOriginXWithValue:newOrigin.x];
//    [self updateOriginYWithValue:newOrigin.y];
    CGRect viewFrame = self.frame;
    viewFrame.origin = newOrigin;
    self.frame = CGRectIntegral(viewFrame);
}

- (void)updateOriginXWithValue:(CGFloat)newOriginX {
    CGRect viewFrame = self.frame;
    viewFrame.origin.x = newOriginX;
    self.frame = CGRectIntegral(viewFrame);
}

- (void)updateOriginYWithValue:(CGFloat)newOriginY {
    CGRect viewFrame = self.frame;
    viewFrame.origin.y = newOriginY;
    self.frame = CGRectIntegral(viewFrame);
}

- (void)updateSizeWithSize:(CGSize)newSize {
//    [self updateHeightWithValue:newSize.height];
//    [self updateWidthWithValue:newSize.width];
    CGRect viewFrame = self.frame;
    viewFrame.size = newSize;
    self.frame = CGRectIntegral(viewFrame);
}

- (void)updateHeightWithValue:(CGFloat)newHeight {
    CGRect viewFrame = self.frame;
    viewFrame.size.height = newHeight;
    self.frame = CGRectIntegral(viewFrame);
}

- (void)updateWidthWithValue:(CGFloat)newWidth {
    CGRect viewFrame = self.frame;
    viewFrame.size.width = newWidth;
    self.frame = CGRectIntegral(viewFrame);
}


@end
