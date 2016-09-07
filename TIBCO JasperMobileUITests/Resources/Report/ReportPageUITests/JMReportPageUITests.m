//
//  JMRunReportTests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMReportPageUITests.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"

NSInteger static kJMRunReportTestCellIndex = 0;

@implementation JMReportPageUITests

#pragma mark - Tests - Main
- (void)testThatReportCanBeRun
{
    [self givenThatReportCanBeRun];
    [self runTestReport];

    [self tryBackToPreviousPage];
}

- (void)testThatUserCanCancelLoadingReport
{
    [self givenThatReportCanBeRun];
    [self tryRunReport];

    [self givenLoadingPopupVisible];
    [self cancelLoading];

    [self givenThatLibraryPageOnScreen];
}

// Title like name of the report
// TODO: do we need this case?

- (void)testThatReportCanBeMarkAsFavorite
{
    [self givenThatReportCanBeRun];
    [self runTestReport];

    [self openMenuActions];
    [self selectActionWithName:@"Mark as Favorite"];

    [self openMenuActions];
    [self selectActionWithName:@"Remove From Favorites"];


    [self tryBackToPreviousPage];
}

// Refresh button
- (void)testThatUserCanRefreshReport
{
    // try run report
    // wait until report is run
    // try open action menu
    // tap 'refresh' button
    // wait until report has being refreshed
    // back to the 'library' page

    [self givenThatReportCanBeRun];
    [self runTestReport];

    [self openMenuActions];
    [self selectActionWithName:@"Refresh"];

    [self givenLoadingPopupNotVisible];
    [self tryBackToPreviousPage];
}

// Edit Filters button
- (void)testThatUserCanSeeChangeInputControlsPage
{
    // try run report
    // wait until report is run
    // try open action menu
    // tap 'edit filters' button
    // wait until 'filters' page appears
    // verify that 'filters' page on screen
    // back to report page

    [self givenThatReportCanBeRun];
    [self runTestReport];

    [self openMenuActions];
    [self selectActionWithName:@"Edit Values"];

    // verify that 'edit values' page is on the screen
    [self waitElementWithAccessibilityId:@"JMInputControlsViewControllerAccessibilityIdentifier"
                                 timeout:kUITestsBaseTimeout];
    // back from edit values page
    XCUIElement *backButton = [self waitBackButtonWithAccessibilityId:@"JMBackButtonAccessibilityId"
                                                    onNavBarWithLabel:@"Filters"
                                                              timeout:kUITestsBaseTimeout];
    [backButton tap];

    // back from report view page
    [self tryBackToPreviousPage];
}

// TODO: Add case when report is without filters

// Save button
- (void)testThatUserCanSeeSaveReportPage
{
    // try run report
    // wait until report is run
    // try open action menu
    // tap 'save report' button
    // wait until 'save report' page appears
    // verify that 'save report' page on screen
    // back to report page
    // back to the 'library' page

    [self givenThatReportCanBeRun];
    [self runTestReport];

    [self openMenuActions];
    [self selectActionWithName:@"Save"];

    // verify that 'save report' page is on the screen
    [self waitElementWithAccessibilityId:@"JMSaveReportViewControllerAccessibilityIdentifier"
                                 timeout:kUITestsBaseTimeout];
    // back from save report page
    [self tryBackToPreviousPage];

    // back from report view page
    [self tryBackToPreviousPage];
}

// Print button
- (void)testThatUserCanPrintReport
{
    // try run report
    // wait until report is run
    // try open action menu
    // tap 'print' button
    // wait until 'print' page appears
    // verify that 'print' page on screen
    // back to report page
    // back to the 'library' page

    [self givenThatReportCanBeRun];
    [self runTestReport];

    [self openMenuActions];
    [self selectActionWithName:@"Print"];

    [self givenLoadingPopupNotVisible];

    // verify that 'print report' page is on the screen
    XCUIElement *printNavBar = [self waitNavigationBarWithLabel:@"Printer Options"
                                                        timeout:kUITestsBaseTimeout];
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"Cancel"
                                                      parentElement:printNavBar
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];

    [self tryBackToPreviousPage];
}

// Info button
- (void)testThatUserCanSeeInfoReportPage
{
    // try run report
    // wait until report is run
    // try open action menu
    // tap 'info' button
    // wait until 'info' page appears
    // verify that 'info' page on screen
    // back to report page
    // back to the 'library' page

    [self givenThatReportCanBeRun];
    [self runTestReport];

    [self openMenuActions];
    [self selectActionWithName:@"Info"];

    [self verifyThatReportInfoPageOnScreen];
    [self closeReportInfoPage];

    [self tryBackToPreviousPage];
}

// Back button like "Library"
// TODO: do we need this case?

// Zoom on Report View screen
// TODO: skip this for now

// Pagination
// TODO: run this test on other test report.
//- (void)testThatUserCanChangePage
//{
//    // try run report
//    // wait until report is run
//    // tap 'next' button
//    // wait until 'next' page appears
//    // back to the 'library' page
//    
//    // TODO: run this test on other test report.
//    XCTFail(@"Not implemented tests");
//}

// JRS 6.0+: Hyperlinks
// TODO: skip this for now

// Chart report with legends
// TODO: skip this for now

// Multilanguage Report
// TODO: skip this for now

// JIVE
// TODO: skip this for now

#pragma mark - Helpers

- (void)givenThatReportCanBeRun
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
    [self givenThatReportCellsOnScreen];
}

- (void)runTestReport
{
    XCUIElement *testCell = [self waitTestCell];
    XCUIElement *reportNameLabel = testCell.staticTexts[@"JMResourceCellResourceNameLabelAccessibilityId"];
    NSString *reportInfoLabel = reportNameLabel.label;

    [self tryRunReport];

    [self givenLoadingPopupNotVisible];
    
    if ([self verifyIfReportFiltersPageOnScreen]) {
        // Run report
        XCUIElement *runReportButton = [self waitButtonWithAccessibilityId:@"Run Report"
                                                                   timeout:kUITestsBaseTimeout];
        [runReportButton tap];
    }

    [self givenLoadingPopupNotVisible];

    [self verifyThatReportPageOnScreenWithReportName:reportInfoLabel];
}

- (void)tryRunReport
{
    XCUIElement *testCell = [self testCell];
    [testCell tap];
}

- (XCUIElement *)waitTestCell
{
    XCUIElement *testCell = [self testCell];
    [self waitElement:testCell
              timeout:kUITestsBaseTimeout];
    return testCell;
}

- (XCUIElement *)testCell
{
    XCUIElement *testCell = [self.application.collectionViews.cells elementBoundByIndex:kJMRunReportTestCellIndex];
    return testCell;
}

- (void)cancelLoading
{
    XCUIElement *loadingPopup = [self findElementWithAccessibilityId:@"JMCancelRequestPopupAccessibilityId"];
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"Cancel"
                                                      parentElement:loadingPopup
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

#pragma mark - Verifies
- (BOOL)verifyIfReportFiltersPageOnScreen
{
    [self givenLoadingPopupNotVisible];

    BOOL isFilterPage = NO;
    XCUIElement *filtersNavBar = [self findNavigationBarWithLabel:@"Filters"];
    isFilterPage = filtersNavBar.exists;
    return isFilterPage;
}

- (void)verifyThatReportPageOnScreenWithReportName:(NSString *)reportName
{
    [self waitNavigationBarWithLabel:reportName
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatReportInfoPageOnScreen
{
    [self waitElementWithAccessibilityId:@"JMReportInfoViewControllerAccessibilityId"
                                 timeout:kUITestsBaseTimeout];
}

- (void)closeReportInfoPage
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:nil];
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"Cancel"
                                                      parentElement:navBar
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

@end
