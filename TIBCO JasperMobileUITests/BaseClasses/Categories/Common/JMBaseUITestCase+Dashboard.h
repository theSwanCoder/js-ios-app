/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

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
