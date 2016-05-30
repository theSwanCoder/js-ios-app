//
//  JMDashboardPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMDashboardPageUITests.h"

@implementation JMDashboardPageUITests

#pragma mark - Tests

//User should see the dashboard
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    > User should see dashboard
- (void)testThatUserCanSeeDashboardPage
{
//    XCTFail(@"Not implemented tests");
}

//Loader (Canceling Dashboard)
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the any dashboard
//    > User should see loader
//    < Tap Cancel button on the loader dialog
//    > Dashboard shouldn't run. Library screen should appear
- (void)testThatUserCanLoaderVisibleBeforeDashboard
{
//    XCTFail(@"Not implemented tests");
}

//Back button like title of the previous screen
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Tap back button
//    > Library screen should appears
- (void)testThatBackButtonHasCorrectTitle
{
//    XCTFail(@"Not implemented tests");
}

//Title like name of the dashboard
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    > User should see title like name of the dashboard
- (void)testThatPageHasCorrectTitle
{
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
}

//Refresh button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Tap Refresh button
//    > Dashboard view screen should refresh
- (void)testThatRefreshButtonWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Print button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Tap Print button
//    > Print Options dialog (screen for iPhone) should appear
- (void)testThatPrintButtonWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Info button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Tap Info button
//    > User should see info dialog (screen for iPhone) about the dashboard
- (void)testThatInfoButtonWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
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

@end
