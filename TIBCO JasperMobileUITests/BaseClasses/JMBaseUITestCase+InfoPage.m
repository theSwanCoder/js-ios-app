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
    XCUIElement *infoButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                 identifier:@"More Info"
                                              parentElement:cell
                                                    timeout:kUITestsBaseTimeout];
    if (infoButton.exists) {
        [infoButton tap];
    } else {
        XCTFail(@"Info button doesn't exist");
    }
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
    XCUIElement *cancelButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                         text:JMLocalizedString(@"dialog_button_cancel")
                                                parentElement:navBar
                                                      timeout:kUITestsBaseTimeout];
    if (cancelButton.exists) {
        [cancelButton tap];
    } else {
        XCTFail(@"Cancel button wasn't found");
    }
}

- (void)verifyInfoPageOnScreenForPageWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *infoPage = [self waitElementMatchingType:XCUIElementTypeOther
                                               identifier:accessibilityId
                                                  timeout:kUITestsBaseTimeout];
    if (!infoPage.exists) {
        XCTFail(@"Info page with id (%@) wasn't found", accessibilityId);
    }
}

#pragma mark - Reports
- (void)openInfoPageForTestReportFromSectionWithName:(NSString *)sectionName
{
    XCUIElement *reportCell = [self searchTestReportInSectionWithName:sectionName];
    [self openInfoPageFromCell:reportCell];
    [self verifyThatReportInfoPageOnScreen];
}

- (void)verifyThatInfoPageForTestReportHasBackButton
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:kTestReportName];
    XCUIElement *backButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                       text:@"Back"
                                              parentElement:navBar
                                                    timeout:0];
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
- (void)openInfoPageForTestDashboardFromSectionWithName:(NSString *)sectionName
{
    XCUIElement *dashboardCell = [self searchTestDashboardInSectionWithName:sectionName];
    [self openInfoPageFromCell:dashboardCell];
    [self verifyThatDashboardInfoPageOnScreen];
}

- (void)verifyThatInfoPageForTestDashboardHasBackButton
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:kTestDashboardName];
    XCUIElement *backButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                       text:@"Back"
                                              parentElement:navBar
                                                    timeout:0];
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

- (void)openInfoPageForTestFolderFromSectionWithName:(NSString *)sectionName
{
    XCUIElement *folderCell = [self searchTestFolderInSectionWithName:sectionName];
    [self openInfoPageFromCell:folderCell];
    [self verifyThatFolderInfoPageOnScreen];
}

- (void)verifyThatInfoPageForTestFolderHasBackButton
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:kTestFolderName];
    XCUIElement *backButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                       text:@"Back"
                                              parentElement:navBar
                                                    timeout:0];
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
