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


+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    if (!hexString || [hexString length] == 0) {
        return [UIColor clearColor];
    }
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    if ([hexString length] > 1) {
        [scanner setScanLocation:1]; // bypass '#' character
    }
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIColor *)highlitedColorForColor:(UIColor *)color
{
    CGFloat alphaComponent;
    CGFloat whiteComponent;
    if ([color getWhite:&whiteComponent alpha:&alphaComponent]) {
        return [UIColor colorWithWhite:[self getHighlitedComponentFrom:whiteComponent]
                                 alpha:alphaComponent];
    }
    
    CGFloat redComponent, greenComponent, blueComponent;
    if ([color getRed:&redComponent green:&greenComponent blue:&blueComponent alpha:&alphaComponent]) {
        return [UIColor colorWithRed:[self getHighlitedComponentFrom:redComponent]
                               green:[self getHighlitedComponentFrom:greenComponent]
                                blue:[self getHighlitedComponentFrom:blueComponent]
                               alpha:alphaComponent];
    }
    
    CGFloat hueComponent, saturationComponent, brightnessComponent;
    if ([color getHue:&hueComponent saturation:&saturationComponent brightness:&brightnessComponent alpha:&alphaComponent]) {
        return [UIColor colorWithHue:[self getHighlitedComponentFrom:hueComponent]
                          saturation:[self getHighlitedComponentFrom:saturationComponent]
                          brightness:[self getHighlitedComponentFrom:brightnessComponent]
                               alpha:alphaComponent];
    }
    return [UIColor whiteColor];
}

+ (CGFloat) getHighlitedComponentFrom:(CGFloat)component
{
    CGFloat differents = 0.6f;
    if (component + differents <= 1) {
        return component + differents;
    }
    if (component - differents >= 0) {
        return component - differents;
    }
    return component;
}
@end
