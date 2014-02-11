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
//  JMUtils.h
//  Jaspersoft Corporation
//

#import <Foundation/Foundation.h>
#import "JMResourceClientHolder.h"
#import "JMServerProfile.h"

extern CGFloat kJMNoEdgesInset;

/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.6
 */
@interface JMUtils : NSObject

/**
 Sets title equal to resource's name or profile's alias if resource is <b>nil</b>
 
 @param viewController A viewController for which title will be set
 */
+ (void)setTitleForResourceViewController:(UIViewController <JMResourceClientHolder> *)viewController;

/**
 Sets background images to the button.
 
 @param button The button for which background images will be set
 @param imageName A name of the image for button's normal state (can be "nil")
 @param highlightedImageName A name of the image for button's highlighted state (can be "nil")
 @param edgesInset An inset for all edges
 */
+ (void)setBackgroundImagesForButton:(UIButton *)button imageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName edgesInset:(CGFloat)edgesInset;

/**
 Returns localized title for menu item (Library, Repository, Favorites etc) depends
 on item's tag
 
 @param tag A tag for the item
 @return A localized title for menu item
 */
+ (NSString *)localizedTitleForMenuItemByTag:(NSInteger)tag;

/**
 Checks if specified view controller is presented on screen
 
 @param viewController A view controller
 @return YES if view controller is presented on screen, otherwise returns NO
 */
+ (BOOL)isViewControllerVisible:(UIViewController *)viewController;

/**
 Validates report name and directory to store report

 @param reportName A report name to validate. It needs to be unique, without /: characters, not empty, and less or equals than 250 symbols (last 5 are reserved for extension)
 @param extension A report file extension. Optional, can be provided to validate uniqueness in file system
 @return YES if report name is valid, otherwise returns NO
 */
+ (BOOL)validateReportName:(NSString *)reportName extension:(NSString *)extension errorMessage:(NSString **)errorMessage;

/**
 Returns full path of report directory located in NSDocumentDirectory directory for NSUserDomainMask domain

 @return full path of report directory
*/
+ (NSString *)documentsReportDirectoryPath;

/**
 Checks if iOS version (foundation number) is 7 or higher
*/
+ (BOOL)isFoundationNumber7OrHigher;

/**
 Sends "changeServerProfile" notification to defaultCenter
 
 @param serverProfile A profile that will be provided to receiver via userInfo dictionary (kJMServerProfileKey key)
 */
+ (void)sendChangeServerProfileNotificationWithProfile:(JMServerProfile *)serverProfile;

/**
 Shows network activity indicator
 */
+ (void)showNetworkActivityIndicator;

/**
 Hides network activity indicator
 */
+ (void)hideNetworkActivityIndicator;

@end
