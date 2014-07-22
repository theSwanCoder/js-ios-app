//
//  UIImage+Additions.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/22/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

+(UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor;

- (UIImage *)colorizeImageWithColor:(id)theColor;

@end
