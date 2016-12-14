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
#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+Search.h"
#import "XCUIElement+Tappable.h"

NSString *const kTestDashboardName = @"1. Supermart Dashboard";

@implementation JMBaseUITestCase (Dashboard)

#pragma mark - Operations

- (void)openTestDashboardPage
{
    [self openTestDashboardPageWithWaitingFinish:YES];
}

- (void)openTestDashboardFromInfoPage
{
    [self openMenuActions];
    [self selectActionWithName:@"Run"];

    [self givenLoadingPopupNotVisible];

    [self tryBackToPreviousPage];
}

- (void)openTestDashboardPageWithWaitingFinish:(BOOL)waitingFinish
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatDashboardCellsOnScreen];

    [self searchTestDashboardInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self tryOpenTestDashboard];

    if (waitingFinish) {
        // We can have two times when loading up and down
        // first time loading 'dashboard info' and second one - loading dashboard
        [self givenLoadingPopupNotVisible];
        [self givenLoadingPopupNotVisible];

        // Could be several hover items which visible while dashlet in loading process (in test dashboard - 5)
        [self waitElementMatchingType:XCUIElementTypeStaticText
                                 text:@"Loading..."
                        parentElement:nil
                  shouldBeInHierarchy:NO
                              timeout:kUITestsResourceLoadingTimeout];
    }
}

- (void)closeTestDashboardPage
{
    [self tryBackToPreviousPage];
}

- (void)cancelOpeningTestDashboardPage
{
    XCUIElement *loadingPopup = [self waitElementMatchingType:XCUIElementTypeOther
                                                   identifier:@"JMCancelRequestPopupAccessibilityId"
                                                      timeout:0];
    [self tapButtonWithText:JMLocalizedString(@"dialog_button_cancel")
              parentElement:loadingPopup
                shouldCheck:YES];
}

- (void)refreshDashboard
{
    [self openMenuActions];
    [self selectActionWithName:@"Refresh"];

    [self givenLoadingPopupNotVisible];
}

- (void)openPrintDashboardPage
{
    [self openMenuActions];
    [self selectActionWithName:@"Print"];
    [self givenLoadingPopupNotVisible];
}

- (void)closePrintDashboardPage
{
    // verify that 'print report' page is on the screen
    [self tapCancelButtonOnNavBarWithTitle:@"Printer Options"];
}

#pragma mark - Helpers

- (XCUIElement *)searchTestDashboardInSectionWithName:(NSString *)sectionName
{
    [self performSearchResourceWithName:kTestDashboardName
                      inSectionWithName:sectionName];

    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];

    XCUIElement *testCell = [self testDashboardCell];
    return testCell;
}

- (void)tryOpenTestDashboard
{
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
    XCUIElement *testCell = [self testDashboardCell];
    [testCell tapByWaitingHittable];
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
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Name"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Description"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"URI"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Type"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Version"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Creation Date"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Modified Date"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
}

- (void)givenThatDashboardCellsOnScreen
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self selectFilterBy:@"Dashboards"
      inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self givenThatCollectionViewContainsListOfCellsInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
}

@end
