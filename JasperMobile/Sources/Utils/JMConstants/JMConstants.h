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
//  JMConstants.h
//  TIBCO JasperMobile
//

/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Alexey Gubarev ogubarie@tibco.com
 @author Aleksandr Dakhno odahno@tibco.com
 
 @since 1.6
 */

#import <Foundation/Foundation.h>

// Application name with trademarks
extern NSString * const kJMAppName;

// Constants for NSUserDefaults
extern NSString * const kJMDefaultsCurrentVersion;
extern NSString * const kJMDefaultsIntroDidApear;

// Notifications
extern NSString * const kJMResetApplicationNotification;
extern NSString * const kJMFavoritesDidChangedNotification;
extern NSString * const kJMSavedResourcesDidChangedNotification;
extern NSString * const kJMExportedResourceDidLoadNotification;
extern NSString * const kJMExportedResourceDidCancelNotification;
extern NSString * const JMServerProfileDidChangeNotification;

// Shared keys for dictionary
extern NSString * const kJMTitleKey;
extern NSString * const kJMValueKey;
extern NSString * const kJMPageAccessibilityIdKey;
extern NSString * const kJMServerProfileKey;
extern NSString * const kJMResourceLookup;
extern NSString * const kJMInputControls;
extern NSString * const kJMLoadRecursively;
extern NSString * const kJMResourcesTypes;
extern NSString * const kJMSearchQuery;
extern NSString * const kJMSortBy;
extern NSString * const kJMFilterByTag;
extern NSString * const kJMReportKey;
extern NSString * const kJMDashboardKey;

// Settings keys
extern NSString * const kJMDefaultSendingCrashReport;
extern NSString * const kJMUserAcceptAgreement;
extern NSString * const kJMDefaultSendingAutoFillLoginData;

// Demo server parameters
extern NSString * const kJMDemoServerAlias;
extern NSString * const kJMDemoServerUrl;
extern NSString * const kJMDemoServerOrganization;
extern NSString * const kJMDemoServerUsername;
extern NSString * const kJMDemoServerPassword;

// Emails for feedbacks
extern NSString * const kFeedbackPrimaryEmail;
extern NSString * const kFeedbackSecondaryEmail;

// Report directory
extern NSString * const kJMReportsDirectory;

// Saved Items ws types
extern NSString * const kJMSavedReportUnit;
extern NSString * const kJMTempExportedReportUnit;

// Schedules Items
extern NSString * const kJMScheduleUnit;

// Name of the main report file (outputResource)
extern NSString * const kJMReportFilename;

// Name of the thumbnail image file for saved reports
extern NSString * const kJMThumbnailImageFileName;

// Error domain for report loader
extern NSString * const kJMReportLoaderErrorDomain;


// Privacy Policy Link
extern NSString * const kJMPrivacyPolicyURI;

// Limit of pages for saving report to HTML format
extern NSInteger  const kJMSaveReportMaxRangePages;

// Limit of resource for loading from JRS
extern NSInteger  const kJMResourceLimit;
extern NSInteger  const kJMRecentResourcesLimit;

// Name of the default theme file
extern NSString * const kJMDefaultThemeFileName;
extern NSString * const kJMThemesFileFormat;
extern NSString * const kJMCurrentThemeFileName;

// Analytics - Common
extern NSString * const kJMAnalyticsServerVersionKey;
extern NSString * const kJMAnalyticsServerEditionKey;
extern NSString * const kJMAnalyticsCategoryKey;
extern NSString * const kJMAnalyticsActionKey;
extern NSString * const kJMAnalyticsLabelKey;

// Analytics - Authentication
extern NSString * const kJMAnalyticsAuthenticationEventCategoryTitle;
extern NSString * const kJMAnalyticsAuthenticationEventActionLoginTitle;
extern NSString * const kJMAnalyticsAuthenticationEventLabelSuccess;
extern NSString * const kJMAnalyticsAuthenticationEventLabelFailure;

// Analytics - Categories
extern NSString * const kJMAnalyticsEventCategoryResource;
extern NSString * const kJMAnalyticsEventCategoryOther;
// Analytics - Resource Actions
extern NSString * const kJMAnalyticsEventActionOpen;
extern NSString * const kJMAnalyticsEventActionPrint;
extern NSString * const kJMAnalyticsEventActionExport;
extern NSString * const kJMAnalyticsEventActionViewed;
// Analytics - Resources Titles
extern NSString * const kJMAnalyticsResourceLabelReportREST;
extern NSString * const kJMAnalyticsResourceLabelReportVisualize;
extern NSString * const kJMAnalyticsResourceLabelDashboardFlow;
extern NSString * const kJMAnalyticsResourceLabelDashboardVisualize;
extern NSString * const kJMAnalyticsResourceLabelSavedResource;
extern NSString * const kJMAnalyticsLabelThumbnail;

// Analytics - Repository
extern NSString * const kJMAnalyticsRepositoryEventCategoryTitle;
extern NSString * const kJMAnalyticsRepositoryEventActionOpen;

// Custom Dimensions
extern NSUInteger  const kJMAnalyticsCustomDimensionServerVersionIndex;
extern NSUInteger  const kJMAnalyticsCustomDimensionServerEditionIndex;

// Login VC
extern NSString *const JMLoginVCLastUserNameKey;
extern NSString *const JMLoginVCLastServerProfileAliasKey;

// Accessibility Identifiers
// Login Page Identifiers
extern NSString *const JMLoginPageAccessibilityId;
extern NSString *const JMLoginPageUserNameTextFieldAccessibilityId;
extern NSString *const JMLoginPagePasswordTextFieldAccessibilityId;
extern NSString *const JMLoginPageServerProfileTextFieldAccessibilityId;
extern NSString *const JMLoginPageTryButtonAccessibilityId;
extern NSString *const JMLoginPageLoginButtonAccessibilityId;

// Server Profiles Identifiers
extern NSString *const JMServerProfilesPageAccessibilityId;
extern NSString *const JMServerProfilesPageAddNewProfileButtonAccessibilityId;
extern NSString *const JMServerProfilesPageServerCellAccessibilityId;
extern NSString *const JMServerProfilesPageListEmptyAccessibilityId;
extern NSString *const JMServerProfilesPageEditProfileAccessibilityId;
extern NSString *const JMServerProfilesPageDeleteProfileAccessibilityId;
extern NSString *const JMServerProfilesPageCloneProfileAccessibilityId;

// New Server Profile Identifiers
extern NSString *const JMNewServerProfilePageAccessibilityId;
extern NSString *const JMNewServerProfilePageSaveAccessibilityId;
extern NSString *const JMNewServerProfilePageNameAccessibilityId;
extern NSString *const JMNewServerProfilePageServerURLAccessibilityId;
extern NSString *const JMNewServerProfilePageOrganizationAccessibilityId;
extern NSString *const JMNewServerProfilePageAskPasswordAccessibilityId;
extern NSString *const JMNewServerProfilePageKeepSessionAccessibilityId;
extern NSString *const JMNewServerProfilePageUseVisualizeAccessibilityId;
extern NSString *const JMNewServerProfilePageUseCacheReportAccessibilityId;

// Onboarding Intro Identifiers
extern NSString *const JMOnboardIntroPageAccessibilityId;
extern NSString *const JMOnboardIntroPageTitlePageAccessibilityId;
extern NSString *const JMOnboardIntroPageDescriptionPageAccessibilityId;
extern NSString *const JMOnboardIntroPageSkipIntroButtonPageAccessibilityId;

// Side Menu Identifiers
extern NSString *const JMSideApplicationMenuAccessibilityId;
extern NSString *const JMSideApplicationMenuVersionLabelAccessibilityId;
extern NSString *const JMSideApplicationMenuMenuButtonAccessibilityId;

extern NSString *const JMLibraryPageAccessibilityId;
extern NSString *const JMRepositoryPageAccessibilityId;
extern NSString *const JMFavoritesPageAccessibilityId;
extern NSString *const JMSavedItemsPageAccessibilityId;
extern NSString *const JMSchedulesPageAccessibilityId;
extern NSString *const JMAppAboutPageAccessibilityId;
extern NSString *const JMSettingsPageAccessibilityId;
extern NSString *const JMFeedbackPageAccessibilityId;
extern NSString *const JMLogoutPageAccessibilityId;

// Privacy Policy Identifiers
extern NSString *const JMEULAPageAccessibilityId;
extern NSString *const JMPrivacyPolicyPageAccessibilityId;

// Resource Collection Identifiers
extern NSString *const JMResourceCollectionPageSearchBarPageAccessibilityId;
extern NSString *const JMResourceCollectionPageActivityLabelAccessibilityId;
extern NSString *const JMResourceCollectionPageNoResultLabelAccessibilityId;
extern NSString *const JMResourceCollectionPageSortByPopupViewPageAccessibilityId;
extern NSString *const JMResourceCollectionPageFilterByPopupViewPageAccessibilityId;
extern NSString *const JMResourceCollectionPageRepresentationButtonViewPageAccessibilityId;

// Resource Collection Cells Identifiers
extern NSString *const JMResourceCollectionPageListLoadingCellAccessibilityId;
extern NSString *const JMResourceCollectionPageGridLoadingCellAccessibilityId;
extern NSString *const JMResourceCollectionPageFileResourceListCellAccessibilityId;
extern NSString *const JMResourceCollectionPageFolderResourceListCellAccessibilityId;
extern NSString *const JMResourceCollectionPageHTMLSavedItemsResourceListCellAccessibilityId;
extern NSString *const JMResourceCollectionPagePDFSavedItemsResourceListCellAccessibilityId;
extern NSString *const JMResourceCollectionPageXLSSavedItemsResourceListCellAccessibilityId;
extern NSString *const JMResourceCollectionPageReportResourceListCellAccessibilityId;
extern NSString *const JMResourceCollectionPageHTMLTempExportedResourceListCellAccessibilityId;
extern NSString *const JMResourceCollectionPagePDFTempExportedResourceListCellAccessibilityId;
extern NSString *const JMResourceCollectionPageXLSTempExportedResourceListCellAccessibilityId;
extern NSString *const JMResourceCollectionPageDashboardResourceListCellAccessibilityId;
extern NSString *const JMResourceCollectionPageLegacyDashboardResourceListCellAccessibilityId;
extern NSString *const JMResourceCollectionPageScheduleResourceListCellAccessibilityId;

extern NSString *const JMResourceCollectionPageFileResourceGridCellAccessibilityId;
extern NSString *const JMResourceCollectionPageFolderResourceGridCellAccessibilityId;
extern NSString *const JMResourceCollectionPageHTMLSavedItemsResourceGridCellAccessibilityId;
extern NSString *const JMResourceCollectionPagePDFSavedItemsResourceGridCellAccessibilityId;
extern NSString *const JMResourceCollectionPageXLSSavedItemsResourceGridCellAccessibilityId;
extern NSString *const JMResourceCollectionPageReportResourceGridCellAccessibilityId;
extern NSString *const JMResourceCollectionPageHTMLTempExportedResourceGridCellAccessibilityId;
extern NSString *const JMResourceCollectionPagePDFTempExportedResourceGridCellAccessibilityId;
extern NSString *const JMResourceCollectionPageXLSTempExportedResourceGridCellAccessibilityId;
extern NSString *const JMResourceCollectionPageDashboardResourceGridCellAccessibilityId;
extern NSString *const JMResourceCollectionPageLegacyDashboardResourceGridCellAccessibilityId;
extern NSString *const JMResourceCollectionPageScheduleResourceGridCellAccessibilityId;
extern NSString *const JMResourceCellResourceInfoButtonAccessibilityId;

// Resource Collection Sorting Identifiers
extern NSString *const JMResourceLoaderSortByNamePageAccessibilityId;
extern NSString *const JMResourceLoaderSortByCreationDatePageAccessibilityId;
extern NSString *const JMResourceLoaderSortByModifiedDatePageAccessibilityId;
extern NSString *const JMResourceLoaderSortByAccessTimePageAccessibilityId;

// Resource Collection Filtering Identifiers
extern NSString *const JMResourceLoaderFilterByAllPageAccessibilityId;
extern NSString *const JMResourceLoaderFilterByReportUnitPageAccessibilityId;
extern NSString *const JMResourceLoaderFilterByDashboardPageAccessibilityId;
extern NSString *const JMResourceLoaderFilterByFolderPageAccessibilityId;
extern NSString *const JMResourceLoaderFilterByFilePageAccessibilityId;
extern NSString *const JMResourceLoaderFilterBySavedItemPageAccessibilityId;
extern NSString *const JMResourceLoaderFilterByHTMLPageAccessibilityId;
extern NSString *const JMResourceLoaderFilterByPDFPageAccessibilityId;
extern NSString *const JMResourceLoaderFilterByXLSPageAccessibilityId;

// Info Pages Identifiers
extern NSString *const JMResourceInfoPageAccessibilityId;
extern NSString *const JMRepositoryInfoPageAccessibilityId;
extern NSString *const JMSavedItemsInfoPageAccessibilityId;
extern NSString *const JMReportInfoPageAccessibilityId;
extern NSString *const JMDashboardInfoPageAccessibilityId;
extern NSString *const JMScheduleInfoPageAccessibilityId;
extern NSString *const JMResourceInfoPageCancelButtonPageAccessibilityId;

extern NSString *const JMResourceInfoPageTitleLabelAccessibilityId;
extern NSString *const JMResourceInfoPageDescriptionLabelAccessibilityId;
extern NSString *const JMResourceInfoPageTypeLabelAccessibilityId;
extern NSString *const JMResourceInfoPageUriLabelAccessibilityId;
extern NSString *const JMResourceInfoPageVersionLabelAccessibilityId;
extern NSString *const JMResourceInfoPageCreationDateLabelAccessibilityId;
extern NSString *const JMResourceInfoPageModifiedDateLabelAccessibilityId;
extern NSString *const JMResourceInfoPageFormatLabelAccessibilityId;
extern NSString *const JMResourceInfoPageScheduleOwnerLabelAccessibilityId;
extern NSString *const JMResourceInfoPageScheduleStateLabelAccessibilityId;
extern NSString *const JMResourceInfoPageSchedulePreviousFireTimeLabelAccessibilityId;

// Menu Actions View Identifiers
extern NSString *const JMMenuActionsViewAccessibilityId;
extern NSString *const JMMenuActionsViewActionButtonAccessibilityId;
extern NSString *const JMMenuActionsViewSortActionAccessibilityId;
extern NSString *const JMMenuActionsViewFilterActionAccessibilityId;
extern NSString *const JMMenuActionsViewMarkAsFavoriteActionAccessibilityId;
extern NSString *const JMMenuActionsViewMarkAsUnFavoriteActionAccessibilityId;
extern NSString *const JMMenuActionsViewRefreshActionAccessibilityId;
extern NSString *const JMMenuActionsViewSaveActionAccessibilityId;
extern NSString *const JMMenuActionsViewEditActionAccessibilityId;
extern NSString *const JMMenuActionsViewEditFiltersActionAccessibilityId;
extern NSString *const JMMenuActionsViewDeleteActionAccessibilityId;
extern NSString *const JMMenuActionsViewRenameActionAccessibilityId;
extern NSString *const JMMenuActionsViewInfoActionAccessibilityId;
extern NSString *const JMMenuActionsViewSelectAllActionAccessibilityId;
extern NSString *const JMMenuActionsViewClearSelectionActionAccessibilityId;
extern NSString *const JMMenuActionsViewRunActionAccessibilityId;
extern NSString *const JMMenuActionsViewPrintActionAccessibilityId;
extern NSString *const JMMenuActionsViewOpenInActionAccessibilityId;
extern NSString *const JMMenuActionsViewScheduleActionAccessibilityId;
extern NSString *const JMMenuActionsViewShareActionAccessibilityId;
extern NSString *const JMMenuActionsViewBookmarksActionAccessibilityId;
extern NSString *const JMMenuActionsViewChartTypesActionAccessibilityId;
extern NSString *const JMMenuActionsViewShowExternalDisplayActionAccessibilityId;
extern NSString *const JMMenuActionsViewHideExternalDisplayActionAccessibilityId;

// Buttons Identifiers
extern NSString *const JMBackButtonAccessibilityId;
extern NSString *const JMButtonDoneAccessibilityId;
extern NSString *const JMButtonAcceptAccessibilityId;
extern NSString *const JMButtonCancelAccessibilityId;
extern NSString *const JMButtonFirstAccessibilityId;
extern NSString *const JMButtonPreviousAccessibilityId;
extern NSString *const JMButtonNextAccessibilityId;
extern NSString *const JMButtonLastAccessibilityId;

// Custom Views Identifiers
extern NSString *const JMCancelRequestPopupAccessibilityId;
