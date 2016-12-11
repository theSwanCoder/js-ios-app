//
// Created by Aleksandr Dakhno on 9/7/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase.h"

extern NSString *const kTestDashboardName;

@interface JMBaseUITestCase (Dashboard)
- (void)openTestDashboardPage;
- (void)openTestDashboardFromInfoPage;
- (void)openTestDashboardPageWithWaitingFinish:(BOOL)waitingFinish;
- (void)closeTestDashboardPage;
- (void)cancelOpeningTestDashboardPage;
- (void)refreshDashboard;

// Printing
- (void)openPrintDashboardPage;
- (void)closePrintDashboardPage;

- (XCUIElement *)searchTestDashboardInSectionWithName:(NSString *)sectionName;

// Verifying
- (void)verifyThatDashboardInfoPageOnScreen;
- (void)verifyThatDashboardInfoPageContainsCorrectDataForDashboardWithName:(NSString *)dashboardName;

- (void)givenThatDashboardCellsOnScreen;
@end