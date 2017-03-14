/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


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

+ (UIColor *)colorWithRedComponent:(CGFloat)redComponent greenComponent:(CGFloat)greenComponent blueComponent:(CGFloat)blueComponent
{
    return [UIColor colorWithRed:[self rgbComponent:redComponent]
                           green:[self rgbComponent:greenComponent]
                            blue:[self rgbComponent:blueComponent]
                           alpha:1];
}

+ (UIColor *)сolorFromColor:(UIColor *)color differents:(CGFloat)differents increase:(BOOL)increase
{
    CGFloat alphaComponent;
    CGFloat whiteComponent;
    
    CGFloat redComponent, greenComponent, blueComponent;
    if ([color getRed:&redComponent green:&greenComponent blue:&blueComponent alpha:&alphaComponent]) {
        return [UIColor colorWithRed:[self getHighlitedComponentFrom:redComponent differents:differents increase:increase]
                               green:[self getHighlitedComponentFrom:greenComponent differents:differents increase:increase]
                                blue:[self getHighlitedComponentFrom:blueComponent differents:differents increase:increase]
                               alpha:alphaComponent];
    }

    if ([color getWhite:&whiteComponent alpha:&alphaComponent]) {
        return [UIColor colorWithWhite:[self getHighlitedComponentFrom:whiteComponent differents:differents increase:increase]
                                 alpha:alphaComponent];
    }

    CGFloat hueComponent, saturationComponent, brightnessComponent;
    if ([color getHue:&hueComponent saturation:&saturationComponent brightness:&brightnessComponent alpha:&alphaComponent]) {
        return [UIColor colorWithHue:[self getHighlitedComponentFrom:hueComponent differents:differents increase:increase]
                          saturation:[self getHighlitedComponentFrom:saturationComponent differents:differents increase:increase]
                          brightness:[self getHighlitedComponentFrom:brightnessComponent differents:differents increase:increase]
                               alpha:alphaComponent];
    }
    return [UIColor whiteColor];
}

+ (CGFloat) getHighlitedComponentFrom:(CGFloat)component differents:(CGFloat)differents increase:(BOOL)increase
{
    if (increase) {
        if (component + differents <= 1) {
            return component + differents;
        }
        if (component - differents >= 0) {
            return component - differents;
        }
    } else {
        if (component - differents <= 1) {
            return component - differents;
        }
        if (component + differents >= 0) {
            return component + differents;
        }
    }
    return component;
}
@end
