/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
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
