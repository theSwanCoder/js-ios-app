//
//  UIImage+Additions.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/22/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

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

@end
