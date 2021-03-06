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


//
//  JMResourcesListLoader.h
//  TIBCO JasperMobile
//

/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 1.9
 */
#import <UIKit/UIKit.h>

@interface UIColor (RGBComponent)

/**
 Returns an rgb color component as normalized value required by colorWithRed:green:blue:alpha: method
 */
+ (CGFloat)rgbComponent:(CGFloat)color;

/**
 Returns an color from hex string. Assumes input like "#00FF00" (#RRGGBB).
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString;

+ (UIColor *)colorWithRedComponent:(CGFloat)redComponent greenComponent:(CGFloat)greenComponent blueComponent:(CGFloat)blueComponent;

+ (UIColor *)сolorFromColor:(UIColor *)color differents:(CGFloat)differents increase:(BOOL)increase;

@end
