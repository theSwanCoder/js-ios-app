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


//
//  JMThemesManager.h
//  TIBCO JasperMobile
//

/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 2.2
 */

#import <Foundation/Foundation.h>

@interface JMThemesManager : NSObject

+ (instancetype) sharedManager;

- (void) applyCurrentTheme;

- (BOOL) applyThemeWithURL:(NSURL *)themeURL error:(NSError **)error;

@end


@interface JMThemesManager (UIFont)

+ (UIFont *)navigationBarTitleFont;

+ (UIFont *)navigationItemsFont;

+ (UIFont *)tableViewCellTitleFont;

+ (UIFont *)tableViewCellDetailFont;

+ (UIFont *)tableViewCellDetailErrorFont;

+ (UIFont *)resourcesActivityTitleFont;

+ (UIFont *)collectionResourceNameFont;

+ (UIFont *)collectionResourceDescriptionFont;

+ (UIFont *)collectionLoadingFont;

+ (UIFont *)menuItemTitleFont;

+ (UIFont *)menuItemDescriptionFont;

+ (UIFont *)loginInputControlsFont;

@end

@interface JMThemesManager (UIColor)

// Login View
- (UIColor *)loginViewBackgroundColor;

- (UIColor *)loginViewPlaceholderBackgroundColor;

- (UIColor *)loginViewTextFieldsBackgroundColor;

- (UIColor *)loginViewTextFieldsTextColor;

- (UIColor *)loginViewLoginButtonBackgroundColor;

- (UIColor *)loginViewLoginButtonTextColor;

- (UIColor *)loginViewTryDemoButtonBackgroundColor;

- (UIColor *)loginViewTryDemoButtonTextColor;

// Menu View
- (UIColor *)menuViewBackgroundColor;

- (UIColor *)menuViewTextColorColor;

- (UIColor *)menuViewSelectedTextColorColor;

- (UIColor *)menuViewSeparatorColor;

// Server Profiles
- (UIColor *)serversViewBackgroundColor;

- (UIColor *)serverProfilePreviewBackgroundColor;

- (UIColor *)serverProfileTitleTextColor;

- (UIColor *)serverProfileDetailsTextColor;

- (UIColor *)serverProfileSaveButtonBackgroundColor;

- (UIColor *)serverProfileSaveButtonTextColor;



// Common

- (UIColor *)viewBackgroundColor;

- (UIColor *)barsBackgroundColor;

- (UIColor *)barItemsTextColor;

- (UIColor *)popupsBackgroundColor;

- (UIColor *) tableViewCellTitleColor;

- (UIColor *) tableViewCellErrorColor;

- (UIColor *) textFieldBackgroundColor;

- (UIColor *) textFieldEditableTextColor;

- (UIColor *) textFieldUnEditableTextColor;



- (UIColor *)collectionViewBackgroundColor;


@end