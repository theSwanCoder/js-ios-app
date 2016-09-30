//
// Created by Aleksandr Dakhno on 9/7/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Dashboard.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Section.h"

NSString *const kTestDashboardName = @"1. Supermart Dashboard";

@implementation JMBaseUITestCase (Dashboard)

#pragma mark - Operations

- (void)openTestDashboardPage
{
    [self openTestDashboardPageWithWaitingFinish:YES];
}

- (void)openTestDashboardPageWithWaitingFinish:(BOOL)waitingFinish
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatDashboardCellsOnScreen];

    [self searchTestDashboard];
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

- (void)openDashboardInfoPage
{
    [self openMenuActions];
    [self selectActionWithName:@"Info"];
    [self givenThatDashboardInfoPageOnScreen];
}

- (void)closeDashboardInfoPage
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:nil];
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"Cancel"
                                                      parentElement:navBar
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

- (void)markDashboardAsFavoriteFromInfoPage
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:kTestDashboardName
                                                   timeout:kUITestsBaseTimeout];
    XCUIElement *favoriteButton = [self waitButtonWithAccessibilityId:@"make favorite item"
                                                        parentElement:navBar
                                                              timeout:kUITestsBaseTimeout];
    [favoriteButton tap];
}

- (void)unmarkDashboardFromFavoriteFromInfoPage
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:kTestDashboardName
                                                   timeout:kUITestsBaseTimeout];
    XCUIElement *favoriteButton = [self waitButtonWithAccessibilityId:@"favorited item"
                                                        parentElement:navBar
                                                              timeout:kUITestsBaseTimeout];
    [favoriteButton tap];
}


- (void)markDashboardAsFavoriteFromActionsMenu
{
    [self openMenuActions];
    [self selectActionWithName:@"Mark as Favorite"];
}

- (void)unmarkDashboardFromFavoriteFromActionsMenu
{
    [self openMenuActions];
    [self selectActionWithName:@"Remove From Favorites"];
}

- (void)markDashboardAsFavoriteFromNavigationBar
{

}

- (void)unmarkDashboardFromFavoriteFromNavigationBar
{

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

- (void)searchTestDashboard
{
    [self searchResourceWithName:kTestDashboardName
    inSectionWithAccessibilityId:@"JMLibraryPageAccessibilityId"];
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

- (void)givenThatDashboardInfoPageOnScreen
{
    [self waitElementWithAccessibilityId:@"JMDashboardInfoViewControllerAccessibilityId"
                                 timeout:kUITestsBaseTimeout];
}

@end
