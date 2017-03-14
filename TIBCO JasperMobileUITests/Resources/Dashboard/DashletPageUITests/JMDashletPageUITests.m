/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMDashletPageUITests.h"
#import "JMBaseUITestCase+Dashboard.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Buttons.h"
#import "XCUIElement+Tappable.h"

static NSString *const kDashletName = @"13. Top Fives Report";

@implementation JMDashletPageUITests

#pragma mark - Setup

- (void)setUp
{
    [super setUp];
    
    [self openTestDashboardPage];
}

- (void)tearDown
{
    [self closeTestDashboardPage];
    
    [super tearDown];
}

#pragma mark - JMBaseUITestCaseProtocol

- (NSInteger)testsCount
{
    return 8;
}

#pragma mark - Tests

//User should see selected dashlet on the separate screen
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Tap on the any dashlet
//    > User should see selected dashlet on the separate screen
- (void)testThatUserCanSeeSelectedDashlet
{
    [self openTestDashletWithHyperlinks];
    [self closeTestDashlet];
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
    [self openTestDashletWithHyperlinks];
    [self verifyThatDashletPageHasCorrentBackButton];
    [self closeTestDashlet];
}

//Title like name of the dashlet
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Open any dashlet
//    > User should see title like name of the dashlet
- (void)testThatPageHasCorrectTitle
{
    [self openTestDashletWithHyperlinks];
    [self verifyThatDashletPageHasCorrectTitle];
    [self closeTestDashlet];
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
    [self openTestDashletWithHyperlinks];
    
    XCUIElement *webView = [self.application.webViews elementBoundByIndex:0];
    [self waitElementReady:webView
                   timeout:kUITestsBaseTimeout];
    [webView pinchWithScale:2
                   velocity:1];
    sleep(kUITestsElementAvailableTimeout);
    [self closeTestDashlet];
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
    [self openTestDashletWithHyperlinks];
    
    [self openTestHyperlinkPage];
    [self verifyThatReportFromTestHypelinkOnScreen];
    [self closeTestHyperlinkPage];
    [self closeTestDashlet];
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
//    TODO: remove this case, because of 'native input controls change' feature.
    [self openTestDashletWithHyperlinks];
    [self closeTestDashlet];
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
    [self openTestDashletWithChartTypes];
    
    XCUIElement *chartTypeElement = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                             text:@"Store Sales" // We don't have translation for this string
                                                          timeout:kUITestsBaseTimeout];
    if (chartTypeElement.exists) {
        [chartTypeElement tapByWaitingHittable];
    } else {
        XCTFail(@"Chart type element wasn't found");
    }
    sleep(3);
    [self closeTestDashlet];
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

#pragma mark - Helpers

- (void)openTestDashletWithHyperlinks
{
    [self tapOnElementWithText:@"Customers"]; // We don't have translation for this string
    [self givenLoadingPopupNotVisible];
}

- (void)closeTestDashlet
{
    [self tapBackButtonWithAlternativeTitle:nil
                          onNavBarWithTitle:nil];
    [self givenLoadingPopupNotVisible];
}

- (void)openTestDashletWithChartTypes
{
    [self tapOnElementWithText:@"Store Cost"]; // We don't have translation for this string
    [self givenLoadingPopupNotVisible];
}

- (void)openTestHyperlinkPage
{
    [self tapOnElementWithText:@"Ida Rodriguez"]; // We don't have translation for this string
    // We can have two times when loading up and down
    // first time loading 'report info' and second one - loading report
    [self givenLoadingPopupVisible];
    [self givenLoadingPopupNotVisible];
    [self givenLoadingPopupVisible];
    [self givenLoadingPopupNotVisible];
}

- (void)tapOnElementWithText:(NSString *)text
{
    XCUIElement *webView = [self.application.webViews elementBoundByIndex:0];
    XCUIElement *element = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                    text:text
                                           parentElement:webView
                                                 timeout:kUITestsBaseTimeout];
    if (element) {
        [element tapByWaitingHittable];
    } else {
        XCTFail(@"Element with text '%@' not found", text);
    }
}

- (void)closeTestHyperlinkPage
{
    [self tryBackToPreviousPage];
}

#pragma mark - Verifying

- (void)verifyThatDashletPageHasCorrentBackButton
{
    [self verifyBackButtonExistWithAlternativeTitle:nil
                                  onNavBarWithTitle:kDashletName];
}

- (void)verifyThatDashletPageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:kDashletName
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatReportFromTestHypelinkOnScreen
{
    [self waitNavigationBarWithLabel:@"09. Customer Detail Report" // We don't have translation for this string
                             timeout:kUITestsBaseTimeout];
}

@end
