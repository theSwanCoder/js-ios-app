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
