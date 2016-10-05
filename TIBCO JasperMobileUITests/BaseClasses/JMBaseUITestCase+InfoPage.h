//
// Created by Aleksandr Dakhno on 10/4/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

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

@end