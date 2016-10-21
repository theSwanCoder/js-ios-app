//
// Created by Aleksandr Dakhno on 9/7/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Dashboard.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+InfoPage.h"

NSString *const kTestDashboardName = @"1. Supermart Dashboard";

@implementation JMBaseUITestCase (Dashboard)

#pragma mark - Operations

- (void)openTestDashboardPage
{
    [self openTestDashboardPageWithWaitingFinish:YES];
}

- (void)openTestDashboardFromInfoPage
{
    [self openMenuActionsWithControllerAccessibilityId:JMDashboardViewerPageAccessibilityId];
    [self selectActionWithName:@"Run"];

    [self givenLoadingPopupNotVisible];
    [self givenLoadingPopupNotVisible];

    [self tryBackToPreviousPage];
}

- (void)openTestDashboardPageWithWaitingFinish:(BOOL)waitingFinish
{
    [self givenThatLibraryPageOnScreen];
//    [self givenThatDashboardCellsOnScreen];

    [self searchTestDashboardInSectionWithName:JMLibraryPageAccessibilityId];
    [self tryOpenTestDashboard];

    [self givenLoadingPopupNotVisible];
    if (waitingFinish) {
        // We can have two times when loading up and down
        // first time loading 'dashboard info' and second one - loading dashboard
        [self givenLoadingPopupNotVisible];
        
        // Could be several hover items which visible while dashlet in loading process (in test dashboard - 5)
        [self waitStaticTextWithAccessibilityId:@"Loading..."
                                  parentElement:nil
                                        visible:false
                                        timeout:kUITestsBaseTimeout];
        [self waitStaticTextWithAccessibilityId:@"Loading..."
                                  parentElement:nil
                                        visible:false
                                        timeout:kUITestsBaseTimeout];
        [self waitStaticTextWithAccessibilityId:@"Loading..."
                                  parentElement:nil
                                        visible:false
                                        timeout:kUITestsBaseTimeout];
        [self waitStaticTextWithAccessibilityId:@"Loading..."
                                  parentElement:nil
                                        visible:false
                                        timeout:kUITestsBaseTimeout];
        [self waitStaticTextWithAccessibilityId:@"Loading..."
                                  parentElement:nil
                                        visible:false
                                        timeout:kUITestsBaseTimeout];
    }
}

- (void)closeTestDashboardPage
{
    [self tryBackToPreviousPage];
}

- (void)cancelOpeningTestDashboardPage
{
    XCUIElement *loadingPopup = [self findElementWithAccessibilityId:@"JMCancelRequestPopupAccessibilityId"];
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"Cancel"
                                                      parentElement:loadingPopup
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

- (void)refreshDashboard
{
    [self openMenuActionsWithControllerAccessibilityId:JMDashboardViewerPageAccessibilityId];
    [self selectActionWithName:@"Refresh"];

    [self givenLoadingPopupNotVisible];
}

- (void)openPrintDashboardPage
{
    [self openMenuActionsWithControllerAccessibilityId:JMDashboardViewerPageAccessibilityId];
    [self selectActionWithName:@"Print"];
}

- (void)closePrintDashboardPage
{
    // verify that 'print report' page is on the screen
    XCUIElement *printNavBar = [self waitNavigationBarWithLabel:@"Printer Options"
                                                        timeout:kUITestsBaseTimeout];
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"Cancel"
                                                      parentElement:printNavBar
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

#pragma mark - Helpers

- (XCUIElement *)searchTestDashboardInSectionWithName:(NSString *)sectionName
{
    [self searchResourceWithName:kTestDashboardName
               inSectionWithName:sectionName];

    [self givenThatCellsAreVisible];

    XCUIElement *testCell = [self testDashboardCell];
    return testCell;
}

- (void)tryOpenTestDashboard
{
    [self givenThatCellsAreVisible];
    XCUIElement *testCell = [self testDashboardCell];
    [testCell tap];
}

- (XCUIElement *)testDashboardCell
{
    XCUIElement *testCell = [self findCollectionViewCellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                           containsLabelWithAccessibilityId:@"JMResourceCellResourceNameLabelAccessibilityId"
                                                                  labelText:kTestDashboardName];
    if (!testCell) {
        XCTFail(@"There isn't test cell");
    }
    return testCell;
}

- (void)verifyThatDashboardInfoPageOnScreen
{
    [self verifyInfoPageOnScreenForPageWithAccessibilityId:@"JMDashboardInfoViewControllerAccessibilityId"];
}

- (void)verifyThatDashboardInfoPageContainsCorrectDataForDashboardWithName:(NSString *)dashboardName
{
    XCUIElement *infoPage = self.application.otherElements[@"JMDashboardInfoViewControllerAccessibilityId"];
    [self waitStaticTextWithAccessibilityId:@"Name"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"Description"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"URI"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"Type"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"Version"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"Creation Date"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"Modified Date"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
}

@end
