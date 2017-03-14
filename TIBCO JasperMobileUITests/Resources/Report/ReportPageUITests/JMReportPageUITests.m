/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMReportPageUITests.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+Favorites.h"
#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+Section.h"

@implementation JMReportPageUITests

#pragma mark - JMBaseUITestCaseProtocol

- (NSInteger)testsCount
{
    return 7;
}

#pragma mark - Tests - Main
- (void)testThatReportCanBeRun
{
    [self openTestReportPage];
    [self verifyThatReportPageOnScreenWithReportName:kTestReportName];
    [self closeTestReportPage];
}

- (void)testThatUserCanCancelLoadingReport
{
    [self openTestReportPageWithWaitingFinish:NO];
    [self cancelOpeningTestReportPage];
    [self givenThatLibraryPageOnScreen];
}

// Title like name of the report
// TODO: do we need this case?

- (void)testThatReportCanBeMarkAsFavorite
{
    [self openTestReportPage];
    
    [self markAsFavoriteFromMenuActions];
    [self unmarkFromFavoritesFromMenuActions];
    
    [self closeTestReportPage];
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
    [self openTestReportPage];
    [self refreshReport];
    [self closeTestReportPage];
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
    [self openTestReportPage];

    [self openReportFiltersPage];
    [self verifyThatReportFiltersPageOnScreen];
    [self closeReportFiltersPage];
    
    [self closeTestReportPage];
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

    [self openTestReportPage];

    [self openMenuActions];
    [self selectActionWithName:JMLocalizedString(@"dialog_button_save")];

    // verify that 'save report' page is on the screen
    [self waitElementMatchingType:XCUIElementTypeOther
                       identifier:@"JMSaveReportViewControllerAccessibilityIdentifier"
                          timeout:kUITestsBaseTimeout];
    // back from save report page
    [self tryBackToPreviousPage];
    
    [self closeTestReportPage];
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

    [self openTestReportPage];

    [self openPrintReportPage];
    
    // verify that 'print report' page is on the screen
    XCUIElement *printNavBar = [self waitNavigationBarWithLabel:@"Printer Options" // We don't have translation for this string
                                                        timeout:kUITestsBaseTimeout];

    if (!printNavBar.exists) {
        XCTFail(@"Print");
    }
    [self closePrintReportPage];
    
    [self closeTestReportPage];
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

    [self openTestReportPage];

    [self openMenuActions];
    [self selectActionWithName:JMLocalizedString(@"action_title_info")];

    [self verifyThatReportInfoPageOnScreen];
    [self closeReportInfoPage];
    
    [self closeTestReportPage];
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

#pragma mark - Verifies
- (BOOL)verifyThatReportFiltersPageOnScreen
{
    [self givenLoadingPopupNotVisible];

    BOOL isFilterPage = NO;
    XCUIElement *filtersNavBar = [self findNavigationBarWithLabel:JMLocalizedString(@"report_viewer_options_title")];
    isFilterPage = filtersNavBar.exists;

    // verify that 'edit values' page is on the screen
    [self waitElementMatchingType:XCUIElementTypeOther
                       identifier:@"JMInputControlsViewControllerAccessibilityIdentifier"
                          timeout:kUITestsBaseTimeout];

    return isFilterPage;
}

- (void)verifyThatReportPageOnScreenWithReportName:(NSString *)reportName
{
    [self waitNavigationBarWithLabel:reportName
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatReportInfoPageOnScreen
{
    [self waitElementMatchingType:XCUIElementTypeOther
                       identifier:@"JMReportInfoViewControllerAccessibilityId"
                          timeout:kUITestsBaseTimeout];
}

- (void)closeReportInfoPage
{
    [self tapCancelButtonOnNavBarWithTitle:nil];
}

@end
