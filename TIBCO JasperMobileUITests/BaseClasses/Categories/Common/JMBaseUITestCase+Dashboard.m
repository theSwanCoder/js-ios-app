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
#import "JMBaseUITestCase+Cells.h"
#import "JMBaseUITestCase+Alerts.h"

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
    [self selectActionWithName:JMLocalizedString(@"action_title_run")];

    // We can have two times when loading up and down
    // first time loading 'dashboard info' and second one - loading dashboard
    [self givenLoadingPopupNotVisible];
    [self givenLoadingPopupNotVisible];

    [self processErrorAlertsIfExistWithTitles:@[@"Visualize Error Domain"] actionBlock:^{
        XCTFail(@"Error of opening dashboard");
    }];

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

        [self processErrorAlertsIfExistWithTitles:@[@"Visualize Error Domain"] actionBlock:^{
            XCTFail(@"Error of opening dashboard");
        }];

        // Could be several hover items which visible while dashlet in loading process (in test dashboard - 5)
        [self waitElementMatchingType:XCUIElementTypeStaticText
                                 text:JMLocalizedString(@"status_loading")
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
    [self selectActionWithName:JMLocalizedString(@"action_title_refresh")];

    [self givenLoadingPopupNotVisible];

    [self processErrorAlertsIfExistWithTitles:@[@"Visualize Error Domain"] actionBlock:^{
        XCTFail(@"Error of refreshing dashboard");
    }];
}

- (void)openPrintDashboardPage
{
    [self openMenuActions];
    [self selectActionWithName:JMLocalizedString(@"action_title_print")];
    [self givenLoadingPopupNotVisible];
}

- (void)closePrintDashboardPage
{
    // verify that 'print report' page is on the screen
    // We don't have localization for this string
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
    XCUIElement *testCell = [self waitCollectionViewCellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                           containsLabelWithAccessibilityId:@"JMResourceCellResourceNameLabelAccessibilityId"
                                                                  labelText:kTestDashboardName
                                                                    timeout:kUITestsElementAvailableTimeout];
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
                             text:JMLocalizedString(@"resource_label_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_description_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_uri_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_type_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_version_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_creationDate_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_modifiedDate_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
}

- (void)givenThatDashboardCellsOnScreen
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_dashboard")
      inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self givenThatCollectionViewContainsListOfCellsInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
}

@end
