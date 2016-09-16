//
//  JMBaseUITestCase+Report.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 9/12/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"

NSString *const kTestReportName = @"01. Geographic Results by Segment Report";
NSString *const kTestReportWithMandatoryFiltersName = @"06. Profit Detail Report";
NSString *const kTestReportWithSingleSelectedControlName = @"04. Product Results by Store Type Report";

@implementation JMBaseUITestCase (Report)

- (void)openTestReportPage
{
    [self openTestReportPageWithWaitingFinish:YES];
}

- (void)openTestReportWithMandatoryFiltersPage
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatReportCellsOnScreen];

    [self tryOpenTestReportWithMandatoryFilters];
    [self givenLoadingPopupNotVisible];
}

- (void)openTestReportWithSingleSelectedControlPage
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatReportCellsOnScreen];
    
    [self tryOpenTestReportWithSingleSelectedControl];
    [self givenLoadingPopupNotVisible];
}

- (void)openTestReportPageWithWaitingFinish:(BOOL)waitingFinish
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatReportCellsOnScreen];

    [self tryOpenTestReport];

    if (waitingFinish) {
        // We can have two times when loading up and down
        // first time loading 'report info' and second one - loading report
        [self givenLoadingPopupNotVisible];
        [self givenLoadingPopupNotVisible];
    }
}

- (void)closeTestReportPage
{
    [self tryBackToPreviousPage];
}

- (void)cancelOpeningTestReportPage
{
    // TODO: the same code is for dashboard - may be make it general?
    XCUIElement *loadingPopup = [self findElementWithAccessibilityId:@"JMCancelRequestPopupAccessibilityId"];
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"Cancel"
                                                      parentElement:loadingPopup
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

- (void)openReportFiltersPage
{
    [self openMenuActions];
    [self selectActionWithName:@"Edit Values"];

    [self givenLoadingPopupNotVisible];
}

- (void)closeReportFiltersPage
{
    [self tryBackToPreviousPage];
}

#pragma mark - Saving

- (void)openSaveReportPage
{
    [self openMenuActions];
    [self selectActionWithName:@"Save"];
}

- (void)closeSaveReportPage
{
    [self tryBackToPreviousPage];
}

#pragma mark - Helpers

- (void)searchTestReport
{
    [self searchResourceWithName:kTestReportName
                       inSection:@"Library"];
}

- (void)tryOpenTestReport
{
    [self searchTestReport];
    [self givenThatCellsAreVisible];

    XCUIElement *testCell = [self testReportCell];
    [testCell tap];
}

- (XCUIElement *)testReportCell
{
    XCUIElement *testCell = [self findCollectionViewCellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                           containsLabelWithAccessibilityId:@"JMResourceCellResourceNameLabelAccessibilityId"
                                                                  labelText:kTestReportName];
    if (!testCell) {
        XCTFail(@"There isn't test cell");
    }
    return testCell;
}

- (void)tryOpenTestReportWithMandatoryFilters
{
    [self searchTestReportWithMandatoryFilters];
    [self givenThatCellsAreVisible];

    XCUIElement *testCell = [self testReportWithMandatoryFiltersCell];
    [testCell tap];
}

- (void)searchTestReportWithMandatoryFilters
{
    [self searchResourceWithName:kTestReportWithMandatoryFiltersName
                       inSection:@"Library"];
}

- (XCUIElement *)testReportWithMandatoryFiltersCell
{
    XCUIElement *testCell = [self findCollectionViewCellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                           containsLabelWithAccessibilityId:@"JMResourceCellResourceNameLabelAccessibilityId"
                                                                  labelText:kTestReportWithMandatoryFiltersName];
    if (!testCell) {
        XCTFail(@"There isn't test cell");
    }
    return testCell;
}

- (void)tryOpenTestReportWithSingleSelectedControl
{
    [self searchTestReportWithSingleSelectedControl];
    [self givenThatCellsAreVisible];
    
    XCUIElement *testCell = [self testReportWithSingleSelectedControl];
    [testCell tap];
}

- (void)searchTestReportWithSingleSelectedControl
{
    [self searchResourceWithName:kTestReportWithSingleSelectedControlName
                       inSection:@"Library"];
}

- (XCUIElement *)testReportWithSingleSelectedControl
{
    XCUIElement *testCell = [self findCollectionViewCellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                           containsLabelWithAccessibilityId:@"JMResourceCellResourceNameLabelAccessibilityId"
                                                                  labelText:kTestReportWithSingleSelectedControlName];
    if (!testCell) {
        XCTFail(@"There isn't test cell");
    }
    return testCell;
}

@end
