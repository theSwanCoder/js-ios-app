/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (InfoPage)

// General methods
- (void)openInfoPageFromCell:(XCUIElement *)cell;
- (void)closeInfoPageFromCell;
- (void)openInfoPageFromMenuActions;
- (void)closeInfoPageFromMenuActions;
- (void)verifyInfoPageOnScreenForPageWithAccessibilityId:(NSString *)accessibilityId;

// Reports
- (void)openInfoPageForTestReportFromSectionWithName:(NSString *)sectionName;
- (void)verifyThatInfoPageForTestReportHasBackButton;
- (void)verifyThatInfoPageForTestReportHasCorrectTitle;
- (void)verifyThatInfoPageForTestReportContainsCorrectData;
- (void)closeInfoPageForTestReport;

// Dashboards
- (void)openInfoPageForTestDashboardFromSectionWithName:(NSString *)sectionName;
- (void)verifyThatInfoPageForTestDashboardHasBackButton;
- (void)verifyThatInfoPageForTestDashboardHasCorrectTitle;
- (void)verifyThatInfoPageForTestDashboardContainsCorrectData;
- (void)closeInfoPageForTestDashboard;

// Folders
- (void)openInfoPageForTestFolderFromSectionWithName:(NSString *)sectionName;
- (void)verifyThatInfoPageForTestFolderHasBackButton;
- (void)verifyThatInfoPageForTestFolderHasCorrectTitle;
- (void)verifyThatInfoPageForTestFolderContainsCorrectData;
- (void)closeInfoPageForTestFolder;

@end
