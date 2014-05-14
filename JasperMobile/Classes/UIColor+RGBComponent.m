//
//  UIColor+RGBComponent.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/8/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "UIColor+RGBComponent.h"

@implementation UIColor (RGBComponent)

+ (CGFloat)rgbComponent:(CGFloat)color
{
    return color / 255.0f;
}

@end
