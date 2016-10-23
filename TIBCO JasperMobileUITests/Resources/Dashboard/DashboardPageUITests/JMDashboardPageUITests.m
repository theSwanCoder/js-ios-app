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

@implementation JMDashboardPageUITests

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
    [self closePrintDashboardPage];
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
    [self waitNavigationBarWithControllerAccessibilityId:kTestDashboardName
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyDashboardPageHasCorrectTitle
{
    [self waitNavigationBarWithControllerAccessibilityId:kTestDashboardName
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyBackButtonHasCorrectTitle
{
    XCUIElement *backButton = [self waitBackButtonWithAccessibilityId:JMDashboardViewerPageAccessibilityId timeout:kUITestsBaseTimeout];
    NSString *backButtonTitle = backButton.label;
    if ([backButtonTitle isEqualToString:JMLocalizedString(@"menuitem_library_label")]) {
        XCTAssert(@"Dashboard viewer page has incorrect back button title");
    }
}

@end
