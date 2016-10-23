//
// Created by Aleksandr Dakhno on 10/4/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (InfoPage)

// General methods
- (void)openInfoPageFromCell:(XCUIElement *)cell;
- (void)openInfoPageFromMenuActions;
- (void)closeInfoPageFromMenuActions;
- (void)verifyInfoPageOnScreenForPageWithAccessibilityId:(NSString *)accessibilityId;

// Reports
- (void)openInfoPageForTestReportFromSectionWithAccessibilityId:(NSString *)accessibilityId;
- (void)verifyThatInfoPageForTestReportHasBackButton;
- (void)verifyThatInfoPageForTestReportHasCorrectTitle;

// Dashboards
- (void)openInfoPageForTestDashboardFromSectionWithAccessibilityId:(NSString *)accessibilityId;
- (void)verifyThatInfoPageForTestDashboardHasBackButton;
- (void)verifyThatInfoPageForTestDashboardHasCorrectTitle;
- (void)verifyThatInfoPageForTestDashboardContainsCorrectData;
- (void)closeInfoPageForTestDashboard;

// Folders
- (void)openInfoPageForTestFolderFromSectionWithAccessibilityId:(NSString *)accessibilityId;
- (void)verifyThatInfoPageForTestFolderHasBackButton;
- (void)verifyThatInfoPageForTestFolderHasCorrectTitle;
- (void)verifyThatInfoPageForTestFolderContainsCorrectData;
- (void)closeInfoPageForTestFolder;

@end
