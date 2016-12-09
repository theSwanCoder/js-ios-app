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
    [self openMenuActions];
    [self selectActionWithName:@"Run"];

    [self givenLoadingPopupNotVisible];
    [self givenLoadingPopupNotVisible];

    [self tryBackToPreviousPage];
}

- (void)openTestDashboardPageWithWaitingFinish:(BOOL)waitingFinish
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatDashboardCellsOnScreen];

    [self searchTestDashboardInSectionWithName:@"Library"];
    [self tryOpenTestDashboard];

    [self givenLoadingPopupNotVisible];
    if (waitingFinish) {
        // We can have two times when loading up and down
        // first time loading 'dashboard info' and second one - loading dashboard
        [self givenLoadingPopupNotVisible];
        
        // Could be several hover items which visible while dashlet in loading process (in test dashboard - 5)
        [self waitElementMatchingType:XCUIElementTypeStaticText
                                 text:@"Loading..."
                        parentElement:nil
                          shouldExist:NO
                              timeout:kUITestsBaseTimeout];
        [self waitElementMatchingType:XCUIElementTypeStaticText
                                 text:@"Loading..."
                        parentElement:nil
                          shouldExist:NO
                              timeout:kUITestsBaseTimeout];
        [self waitElementMatchingType:XCUIElementTypeStaticText
                                 text:@"Loading..."
                        parentElement:nil
                          shouldExist:NO
                              timeout:kUITestsBaseTimeout];
        [self waitElementMatchingType:XCUIElementTypeStaticText
                                 text:@"Loading..."
                        parentElement:nil
                          shouldExist:NO
                              timeout:kUITestsBaseTimeout];
        [self waitElementMatchingType:XCUIElementTypeStaticText
                                 text:@"Loading..."
                        parentElement:nil
                          shouldExist:NO
                              timeout:kUITestsBaseTimeout];
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
                                                      timeout:kUITestsBaseTimeout];
    XCUIElement *cancelButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                         text:JMLocalizedString(@"dialog_button_cancel")
                                                parentElement:loadingPopup
                                                      timeout:0];
    if (cancelButton.exists) {
        [cancelButton tap];
    } else {
        XCTFail(@"Cancel button wasn't found");
    }
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
    XCUIElement *printNavBar = [self waitNavigationBarWithLabel:@"Printer Options"
                                                        timeout:kUITestsBaseTimeout];
    XCUIElement *cancelButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                         text:JMLocalizedString(@"dialog_button_cancel")
                                                parentElement:printNavBar
                                                      timeout:0];
    if (cancelButton.exists) {
        [cancelButton tap];
    } else {
        XCTFail(@"Cancel button wasn't found");
    }
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

@end
