/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.2
 */

@import UIKit;

@interface JMThemesManager : NSObject

+ (instancetype) sharedManager;

- (void) applyCurrentTheme;

- (BOOL) applyThemeWithURL:(NSURL *)themeURL error:(NSError **)error;

@end


@interface JMThemesManager (UIFont)

- (UIFont *)navigationBarTitleFont;

- (UIFont *)navigationItemsFont;

- (UIFont *)tableViewCellTitleFont;

- (UIFont *)tableViewCellDetailFont;

- (UIFont *)tableViewCellErrorFont;

- (UIFont *)resourcesActivityTitleFont;

- (UIFont *)collectionResourceNameFont;

- (UIFont *)collectionResourceDescriptionFont;

- (UIFont *)collectionLoadingFont;

- (UIFont *)menuItemTitleFont;

- (UIFont *)menuItemDescriptionFont;

- (UIFont *)loginInputControlsFont;

- (UIFont *)appAboutTitleFont;

- (UIFont *)appAboutCommonTextFont;

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

- (UIColor *)loginViewTryDemoButtonDisabledBackgroundColor;

- (UIColor *)loginViewTryDemoButtonTextColor;

- (UIColor *)loginViewTryDemoDisabledButtonTextColor;

// Menu View
- (UIColor *)menuViewBackgroundColor;

- (UIColor *)menuViewUserNameTextColor;

- (UIColor *)menuViewAdditionalInfoTextColor;

- (UIColor *)menuViewTextColor;

- (UIColor *)menuViewSelectedTextColor;

- (UIColor *)menuViewSeparatorColor;

// Server Profiles
- (UIColor *)serversViewBackgroundColor;

- (UIColor *)serverProfilePreviewBackgroundColor;

- (UIColor *)serverProfileTitleTextColor;

- (UIColor *)serverProfileDetailsTextColor;

- (UIColor *)serverProfileSaveButtonBackgroundColor;

- (UIColor *)serverProfileSaveButtonTextColor;

// Resource View
- (UIColor *)resourceViewBackgroundColor;

- (UIColor *)resourceViewLoadingCellTitleTextColor;

- (UIColor *)resourceViewLoadingCellActivityIndicatorColor;

- (UIColor *)resourceViewResourceCellTitleTextColor;

- (UIColor *)resourceViewResourceCellDetailsTextColor;

- (UIColor *)resourceViewResourceCellPreviewBackgroundColor;

- (UIColor *)resourceViewNoResultLabelTextColor;

- (UIColor *)resourceViewActivityLabelTextColor;

- (UIColor *)resourceViewActivityActivityIndicatorColor;

- (UIColor *)resourceViewRefreshControlTintColor;

- (UIColor *)resourceViewResourceInfoButtonTintColor;

- (UIColor *)resourceViewResourceFavoriteButtonTintColor;

// Report Options
- (UIColor *)reportOptionsRunReportButtonBackgroundColor;

- (UIColor *)reportOptionsRunReportButtonTextColor;

- (UIColor *)reportOptionsTitleLabelTextColor;

- (UIColor *)reportOptionsNoResultLabelTextColor;

- (UIColor *)reportOptionsItemsSegmentedTintColor;

// Save Report
- (UIColor *)saveReportSaveReportButtonBackgroundColor;

- (UIColor *)saveReportSaveReportButtonTextColor;

// About App
- (UIColor *)aboutAppAppNameTextColor;

- (UIColor *)aboutAppAppAboutTextColor;

- (UIColor *)aboutAppButtonsBackgroundColor;

- (UIColor *)aboutAppButtonsTextColor;


// Common

- (UIColor *)viewBackgroundColor;

- (UIColor *)barsBackgroundColor;

- (UIColor *)barItemsColor;

- (UIColor *)popupsBackgroundColor;

- (UIColor *)popupsTextColor;

- (UIColor *) tableViewCellTitleTextColor;

- (UIColor *) tableViewCellDetailsTextColor;

- (UIColor *) tableViewCellErrorColor;

- (UIColor *) textFieldBackgroundColor;

- (UIColor *) textFieldEditableTextColor;

- (UIColor *) textFieldUnEditableTextColor;

@end
