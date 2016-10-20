//
// Created by Aleksandr Dakhno on 10/4/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+InfoPage.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+Dashboard.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Folders.h"

@implementation JMBaseUITestCase (InfoPage)

#pragma mark - Info Page
- (void)openInfoPageFromCell:(XCUIElement *)cell
{
    XCUIElement *infoButton = [self waitButtonWithAccessibilityId:@"More Info"
                                                    parentElement:cell
                                                          timeout:kUITestsBaseTimeout];
    [infoButton tap];
}

- (void)closeInfoPageFromCell
{
    [self tryBackToPreviousPage];
}

- (void)openInfoPageFromMenuActions
{
    [self openMenuActions];
    [self selectActionWithName:@"Info"];
}

- (void)closeInfoPageFromMenuActions
{
    [self closeInfoPageWithCancelButton];
}

- (void)closeInfoPageWithCancelButton
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:nil];
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"Cancel"
                                                      parentElement:navBar
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

- (void)verifyInfoPageOnScreenForPageWithAccessibilityId:(NSString *)accessibilityId
{
    [self waitElementWithAccessibilityId:accessibilityId
                                 timeout:kUITestsBaseTimeout];
}

#pragma mark - Reports
- (void)openInfoPageForTestReportFromSectionWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *reportCell = [self searchTestReportInSectionWithName:accessibilityId];
    [self openInfoPageFromCell:reportCell];
    [self verifyThatReportInfoPageOnScreen];
}

- (void)verifyThatInfoPageForTestReportHasBackButton
{
    XCUIElement *backButton = [self findBackButtonWithAccessibilityId:@"Back"
                                                    onNavBarWithLabel:kTestReportName];
    if (!backButton.exists) {
        XCTFail(@"Back button doesn't exist on 'Info' page for test report");
    }
}

- (void)verifyThatInfoPageForTestReportHasCorrectTitle
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:kTestReportName];
    if (!navBar.exists) {
        XCTFail(@"Info page for test report has incorrect title");
    }
}

- (void)verifyThatInfoPageForTestReportContainsCorrectData
{
    [self verifyThatReportInfoPageContainsCorrectDataForReportWithName:kTestReportName];
}

- (void)closeInfoPageForTestReport
{
    [self closeInfoPageFromCell];
}

#pragma mark - Dashboards
- (void)openInfoPageForTestDashboardFromSectionWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *dashboardCell = [self searchTestDashboardInSectionWithName:accessibilityId];
    [self openInfoPageFromCell:dashboardCell];
    [self verifyThatDashboardInfoPageOnScreen];
}

- (void)verifyThatInfoPageForTestDashboardHasBackButton
{
    XCUIElement *backButton = [self findBackButtonWithAccessibilityId:@"Back"
                                                    onNavBarWithLabel:kTestDashboardName];
    if (!backButton.exists) {
        XCTFail(@"Back button doesn't exist on 'Info' page for test dashboard");
    }
}

- (void)verifyThatInfoPageForTestDashboardHasCorrectTitle
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:kTestDashboardName];
    if (!navBar.exists) {
        XCTFail(@"Info page for test dashboard has incorrect title");
    }
}

- (void)verifyThatInfoPageForTestDashboardContainsCorrectData
{
    [self verifyThatDashboardInfoPageContainsCorrectDataForDashboardWithName:kTestDashboardName];
}

- (void)closeInfoPageForTestDashboard
{
    [self closeInfoPageFromCell];
}

#pragma mark - Folders

- (void)openInfoPageForTestFolderFromSectionWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *folderCell = [self searchTestFolderInSectionWithName:accessibilityId];
    [self openInfoPageFromCell:folderCell];
    [self verifyThatFolderInfoPageOnScreen];
}

- (void)verifyThatInfoPageForTestFolderHasBackButton
{
    XCUIElement *backButton = [self findBackButtonWithAccessibilityId:@"Back"
                                                    onNavBarWithLabel:kTestFolderName];
    if (!backButton.exists) {
        XCTFail(@"Back button doesn't exist on 'Info' page for test folder");
    }
}

- (void)verifyThatInfoPageForTestFolderHasCorrectTitle
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:kTestFolderName];
    if (!navBar.exists) {
        XCTFail(@"Info page for test folder has incorrect title");
    }
}

- (void)verifyThatInfoPageForTestFolderContainsCorrectData
{
    [self verifyThatFolderInfoPageContainsCorrectDataForFolderWithName:kTestFolderName];
}

- (void)closeInfoPageForTestFolder
{
    [self closeInfoPageFromCell];
}

@end
