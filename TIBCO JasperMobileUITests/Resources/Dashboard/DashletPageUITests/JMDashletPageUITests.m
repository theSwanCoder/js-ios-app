//
//  JMDashletPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMDashletPageUITests.h"

@implementation JMDashletPageUITests

#pragma mark - Tests

//User should see selected dashlet on the separate screen
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Tap on the any dashlet
//    > User should see selected dashlet on the separate screen
- (void)testThatUserCanSeeSelectedDashlet
{
//    XCTFail(@"Not implemented tests");
}

//Back button like title of the dashboard
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Open any dashlet
//    < Tap back button
//    > Dashboard View screen should appears
- (void)testThatBackButtonHasCorrectTitle
{
//    XCTFail(@"Not implemented tests");
}

//Title like name of the dashlet
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Open any dashlet
//    > User should see title like name of the dashlet
- (void)testThatPageHasCorrectTitle
{
//    XCTFail(@"Not implemented tests");
}

//Zoom on Dashlet View screen
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Open any dashlet
//    < Increase the zoom
//    < Decrease the zoom
//    < Verify that dashlet is not scalled if previous dashlet was scalled
//    < Verify interaction
//    > Dashlet should be bigger
//    > Dashlet should be smaller
//    > Dashlet shouldn't be scalled
//    > Interaction works as expect
- (void)testThatZoomWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Hyperlinks
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard with hyperlinks (for instance 1. Supermart Dashboard)
//    < Open dashlet with hyperlinks
//    < Tap on hyperlink
//    > Hyperlink work as expected
- (void)testThatHyperlinksWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Input Controls
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard which has reports with IC (for instance 1.Supermart Dashboard)
//    < Open dashlet with IC
//    < Change IC for any report
//    > Report's IC work as expected
// TODO: Old version
- (void)testThatInputControlsWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Change Chart Type of report
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard with chart reports
//    < Open dashlet with chart
//    < Tap "Chart Types..." button
//    < Select one of chart types
//    < Close "Select Cart Type" window
//    < Tap back button on Dashlet View screen
//    > Chart type of report should be changed. User should see chanched report on Dashboard View screen
- (void)testThatChartTypeCanBeChanged
{
//    XCTFail(@"Not implemented tests");
}

//JIVE
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard with table or crosstab
//    < Open the dashlet with table or crosstab
//    < Verify JIVE operations
//    < Tap back button on Dashlet View screen
//    > JIVE operations work as expected. User should see saved JIVE operations on Dashboard View screen
- (void)testThatJIVEWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

@end
