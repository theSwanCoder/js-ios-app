//
//  JMRunReportTests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMReportPageUITests.h"
#import "JMBaseUITestCase+Helpers.h"

NSInteger static kJMRunReportTestCellIndex = 0;

@implementation JMReportPageUITests

#pragma mark - Tests - Main
- (void)testThatReportCanBeRun
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
    
    [self waitTestCell];
    [self runTestReport];
    [self tryBackToPreviousPage];
}

- (void)testThatUserCanCancelLoadingReport
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
    
    [self waitTestCell];
    [self tryRunReport];

    [self verifyThatLoadingPopupVisible];
    [self cancelLoading];

    [self verifyThatCurrentPageIsLibrary];
}

// Title like name of the report
// TODO: do we need this case?

- (void)testThatReportCanBeMarkAsFavorite
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
    
    [self waitTestCell];
    [self runTestReport];

    [self openMenuActions];

    XCUIElement *menuActionsView = [self waitElementWithAccessibilityId:@"JMMenuActionsViewAccessibilityId"
                                                                visible:true
                                                                timeout:5];

    XCUIElement *removeFromFavoriteButton = menuActionsView.staticTexts[@"Remove From Favorites"];
    if (removeFromFavoriteButton.exists) {
        [removeFromFavoriteButton tap];
    } else {
        XCUIElement *markAsFavoriteButton = menuActionsView.staticTexts[@"Mark as Favorite"];
        if (markAsFavoriteButton.exists) {
            [markAsFavoriteButton tap];

            // Verify that report is mark as favorite
            // TODO: verify in 'Favorite' section
        }
    }

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
    
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
    
    [self waitTestCell];
    [self runTestReport];

    [self openMenuActions];

    XCUIElement *menuActionsView = [self waitElementWithAccessibilityId:@"JMMenuActionsViewAccessibilityId"
                                                                visible:true
                                                                timeout:5];
    XCUIElement *refreshButton = menuActionsView.staticTexts[@"Refresh"];
    if (refreshButton.exists) {
        [refreshButton tap];
    } else {
        XCTFail(@"'Refresh' button isn't visible");
    }
    sleep(2);
    [self verifyThatLoadingPopupNotVisible];
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
    
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
    
    [self waitTestCell];
    [self runTestReport];

    [self openMenuActions];

    XCUIElement *menuActionsView = [self waitElementWithAccessibilityId:@"JMMenuActionsViewAccessibilityId"
                                                                visible:true
                                                                timeout:5];

    XCUIElement *editValuesButton = menuActionsView.staticTexts[@"Edit Values"];
    if (editValuesButton) {
        [editValuesButton tap];
    } else {
        XCTFail(@"'Refresh' button isn't visible");
    }
    // verify that 'edit values' page is on the screen
    [self waitElementWithAccessibilityId:@"JMInputControlsViewControllerAccessibilityIdentifier"
                                 visible:true
                                 timeout:5];
    // back from edit values page
    XCUIElement *backButton = [self waitBackButtonWithAccessibilityId:@"JMBackButtonAccessibilityId"
                                                    onNavBarWithLabel:@"Filters"
                                                              timeout:5];
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
    
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
    
    [self waitTestCell];
    [self runTestReport];

    [self openMenuActions];

    XCUIElement *menuActionsView = [self waitElementWithAccessibilityId:@"JMMenuActionsViewAccessibilityId"
                                                                visible:true
                                                                timeout:5];

    XCUIElement *saveButton = menuActionsView.staticTexts[@"Save"];
    if (saveButton) {
        [saveButton tap];
    } else {
        XCTFail(@"'Refresh' button isn't visible");
    }
    // verify that 'save report' page is on the screen
    [self waitElementWithAccessibilityId:@"JMSaveReportViewControllerAccessibilityIdentifier"
                                 visible:true
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

    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
    
    [self waitTestCell];
    [self runTestReport];

    [self openMenuActions];

    XCUIElement *menuActionsView = [self waitElementWithAccessibilityId:@"JMMenuActionsViewAccessibilityId"
                                                                visible:true
                                                                timeout:5];

    XCUIElement *printButton = menuActionsView.staticTexts[@"Print"];
    if (printButton) {
        [printButton tap];
    } else {
        XCTFail(@"'Refresh' button isn't visible");
    }
    sleep(kUITestsElementAvailableTimeout);
    [self verifyThatLoadingPopupNotVisible];
    // verify that 'print report' page is on the screen
    XCUIElement *printNavBar = [self waitNavigationBarWithLabel:@"Printer Options"
                                                        timeout:kUITestsBaseTimeout];
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"Cancel"
                                                      parentElement:printNavBar
                                                            visible:true
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

    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
    
    [self waitTestCell];
    [self runTestReport];

    [self openMenuActions];

    XCUIElement *menuActionsView = [self waitElementWithAccessibilityId:@"JMMenuActionsViewAccessibilityId"
                                                                visible:true
                                                                timeout:5];

    XCUIElement *infoButton = menuActionsView.staticTexts[@"Info"];
    if (infoButton) {
        [infoButton tap];
    } else {
        XCTFail(@"'Refresh' button isn't visible");
    }
    [self verifyThatReportInfoPageOnScreen];
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

- (void)runTestReport
{
    XCUIElement *testCell = [self testCell];
    XCUIElement *reportNameLabel = testCell.staticTexts[@"JMResourceCellResourceNameLabelAccessibilityId"];
    NSString *reportInfoLabel = reportNameLabel.label;

    [self tryRunReport];

    sleep(2);
    [self verifyThatLoadingPopupNotVisible];

    if ([self verifyIfReportFiltersPageOnScreen]) {
        // Run report
        XCUIElement *runReportButton = [self waitButtonWithAccessibilityId:@"Run Report"
                                                                   timeout:kUITestsBaseTimeout];
        [runReportButton tap];

        sleep(2);
        [self verifyThatLoadingPopupNotVisible];
    }

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
              visible:true
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
                                                            visible:true
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

#pragma mark - Verifies
- (BOOL)verifyIfReportFiltersPageOnScreen
{
    BOOL isFilterPage = NO;
    XCUIElement *filtersNavBar = [self.application.navigationBars elementMatchingType:XCUIElementTypeAny identifier:@"Filters"];
    isFilterPage = filtersNavBar.exists;
    return isFilterPage;
}

- (void)verifyThatReportPageOnScreenWithReportName:(NSString *)reportName
{
    XCUIElement *reportNavBar = [self.application.navigationBars elementMatchingType:XCUIElementTypeAny identifier:reportName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.exists == true"];
    [self expectationForPredicate:predicate
              evaluatedWithObject:reportNavBar
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)verifyThatReportInfoPageOnScreen
{
    XCUIElement *reportInfoPageElement = [self waitElementWithAccessibilityId:@"JMReportInfoViewControllerAccessibilityId"
                                                                      visible:true
                                                                      timeout:kUITestsBaseTimeout];
    NSPredicate *cellsCountPredicate = [NSPredicate predicateWithFormat:@"self.exists == true"];
    [self expectationForPredicate:cellsCountPredicate
              evaluatedWithObject:reportInfoPageElement
                          handler:nil];
    [self waitForExpectationsWithTimeout:kUITestsBaseTimeout
                                 handler:nil];

    XCUIElement *navBar = [self.application.navigationBars elementBoundByIndex:0];
    XCUIElement *cancelButton = navBar.buttons[@"Cancel"];
    if (cancelButton.exists) {
        [cancelButton tap];
    }
}

@end
