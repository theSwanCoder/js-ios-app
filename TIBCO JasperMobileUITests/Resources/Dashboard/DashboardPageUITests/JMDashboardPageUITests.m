//
//  JMDashboardPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMDashboardPageUITests.h"
#import "JMBaseUITestCase+Dashboard.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Favorites.h"
#import "JMBaseUITestCase+InfoPage.h"
#import "JMBaseUITestCase+Printer.h"
#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+Section.h"

@implementation JMDashboardPageUITests

#pragma mark - JMBaseUITestCaseProtocol

- (NSInteger)testsCount
{
    return 8;
}

#pragma mark - Tests

//User should see the dashboard
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    > User should see dashboard
- (void)testThatUserCanSeeDashboardPage
{
    [self openTestDashboardPage];
    [self verifyDashboardPageOnScreen];
    [self closeTestDashboardPage];
}

//Loader (Canceling Dashboard)
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the any dashboard
//    > User should see loader
//    < Tap Cancel button on the loader dialog
//    > Dashboard shouldn't run. Library screen should appear
- (void)testThatUserCanCancelLoadingDashboard
{
    [self openTestDashboardPageWithWaitingFinish:NO];
    [self cancelOpeningTestDashboardPage];
    [self givenThatLibraryPageOnScreen];
}

//Back button like title of the previous screen
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Tap back button
//    > Library screen should appears
- (void)testThatBackButtonHasCorrectTitle
{
    [self openTestDashboardPage];
    [self verifyBackButtonHasCorrectTitle];
    [self closeTestDashboardPage];
}

//Title like name of the dashboard
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    > User should see title like name of the dashboard
- (void)testThatPageHasCorrectTitle
{
    [self openTestDashboardPage];
    [self verifyDashboardPageHasCorrectTitle];
    [self closeTestDashboardPage];
}

//Favorite button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Add dashboard to favorites
//    < Remove dashboard from favorites
//    > Star should be filled after adding the dashboard to favorites
//    > Star should be empty after removing the dashboard from favorites
- (void)testThatFavoriteButtonWorkCorrectly
{
    [self openTestDashboardPage];

    [self markAsFavoriteFromMenuActions];
    [self unmarkFromFavoritesFromMenuActions];

    [self closeTestDashboardPage];
}

//Refresh button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Tap Refresh button
//    > Dashboard view screen should refresh
- (void)testThatRefreshButtonWorkCorrectly
{
    [self openTestDashboardPage];
    [self refreshDashboard];
    [self closeTestDashboardPage];
}

//Print button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Tap Print button
//    > Print Options dialog (screen for iPhone) should appear
- (void)testThatPrintButtonWorkCorrectly
{
    [self openTestDashboardPage];
    [self openPrintDashboardPage];
    
    XCUIElement *errorAlert = [self findAlertWithTitle:@"JSErrorDomain"];
    if (errorAlert.exists) {
    // TODO: should this case be considered as a failure?
        [self tapButtonWithText:JMLocalizedString(@"dialog_button_ok")
                  parentElement:errorAlert
                    shouldCheck:YES];
    } else {
        [self verifyThatPrintPageOnScreen];
        [self closePrintDashboardPage];
    }

    [self closeTestDashboardPage];
}

//Info button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Tap Info button
//    > User should see info dialog (screen for iPhone) about the dashboard
- (void)testThatInfoButtonWorkCorrectly
{
    [self openTestDashboardPage];

    [self openInfoPageFromMenuActions];
    [self verifyThatDashboardInfoPageOnScreen];
    [self closeInfoPageFromMenuActions];

    [self closeTestDashboardPage];
}

//Zoom on Dashboard View screen
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Increase the zoom
//    < Decrease the zoom
//    < Verify that dashboard is not scalled if previous report/dashboard was scalled
//    < Verify interaction
//    > Dashboard should be bigger
//    > Dashboard should be smaller
//    > Dashboard shouldn't be scalled
//    > Interaction should be disabled
- (void)testThatZoomWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

#pragma mark - Verifying

- (void)verifyDashboardPageOnScreen
{
    // TODO: may be need other case
    [self waitNavigationBarWithLabel:kTestDashboardName
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyDashboardPageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:kTestDashboardName
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyBackButtonHasCorrectTitle
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:kTestDashboardName
                                                   timeout:kUITestsBaseTimeout];
    [self verifyButtonExistWithText:JMLocalizedString(@"menuitem_library_label")
                      parentElement:navBar];
}

@end
