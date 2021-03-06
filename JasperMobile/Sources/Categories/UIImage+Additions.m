/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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


#import "UIImage+Additions.h"
#import "UIColor+RGBComponent.h"


@implementation UIImage (Additions)

+(UIImage *)colorizeImage:(UIImage *)baseImage color:(id)theColor {
    UIColor* currentColor = nil;
    if ([theColor isKindOfClass:[UIColor class]]) {
        currentColor = theColor;
    } else if ([theColor isKindOfClass:[NSString class]]) {
        currentColor = [UIColor colorFromHexString:theColor];
    } else {
        return nil;
    }
    
    UIGraphicsBeginImageContext(baseImage.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, baseImage.CGImage);
    [currentColor set];
    CGContextFillRect(ctx, area);
    CGContextRestoreGState(ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextDrawImage(ctx, area, baseImage.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)colorizeImageWithColor:(id)theColor{
    return [UIImage colorizeImage:self color:theColor];
}

- (UIImage *)cropedImageForRect:(CGRect)rect
{
    CGFloat imageWidth = self.size.width;
    
    CGFloat rectWidth = CGRectGetWidth(rect);
    CGFloat rectHeight = CGRectGetHeight(rect);
    
    CGFloat croppedOriginX = 0;
    CGFloat croppedOriginY = 0;
    CGFloat croppedWidth = imageWidth; // always equal width of image
    CGFloat croppedHeight = (imageWidth/rectWidth) * rectHeight; // changed to fill rect
    
    CGFloat scaleFactor = [[UIScreen mainScreen] scale];
    CGRect croppedRect = CGRectMake(croppedOriginX,
                                    croppedOriginY,
                                    croppedWidth * scaleFactor,
                                    croppedHeight *scaleFactor);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], croppedRect);
    UIImage *img = [UIImage imageWithCGImage:imageRef scale:scaleFactor orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    return img;
}

@end
