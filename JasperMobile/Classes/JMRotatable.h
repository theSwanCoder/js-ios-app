/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JMRotatable.h
//  Jaspersoft Corporation
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 Implementations of the `JMRotatable` protocol provide general rotation support for iOS 5 and 6
 
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.6
 */
@protocol JMRotatable <NSObject>

@required

// Returns the interface orientation to use when presenting the view controller;
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

// Return list of supported orientations.
- (NSUInteger)supportedInterfaceOrientations;

// Determine iOS 6 Autorotation
- (BOOL)shouldAutorotate;

// handle iOS 5 Orientation as normal
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
