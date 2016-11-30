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
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+InfoPage.h"

NSString *const kTestReportName = @"01. Geographic Results by Segment Report";
NSString *const kTestReportWithMandatoryFiltersName = @"06. Profit Detail Report";
NSString *const kTestReportWithSingleSelectedControlName = @"04. Product Results by Store Type Report";

@implementation JMBaseUITestCase (Report)

- (void)openTestReportPage
{
    [self openTestReportPageWithWaitingFinish:YES];
}

- (void)openTestReportFromInfoPage
{
    [self openMenuActions];
    [self selectActionWithName:@"Run"];

    [self givenLoadingPopupNotVisible];
    [self givenLoadingPopupNotVisible];

    [self tryBackToPreviousPage];
}

- (void)openTestReportWithMandatoryFiltersPage
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatReportCellsOnScreen];

    [self tryOpenTestReportWithMandatoryFilters];
    // We can have two times when loading up and down
    // first time loading 'report info' and second one - loading report
    [self givenLoadingPopupNotVisible];
    [self givenLoadingPopupNotVisible];
}

- (void)openTestReportWithSingleSelectedControlPage
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatReportCellsOnScreen];
    
    [self tryOpenTestReportWithSingleSelectedControl];
    // We can have two times when loading up and down
    // first time loading 'report info' and second one - loading report
    [self givenLoadingPopupNotVisible];
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
    XCUIElement *loadingPopup = [self waitElementWithAccessibilityId:@"JMCancelRequestPopupAccessibilityId"
                                                             timeout:kUITestsBaseTimeout];
    XCUIElement *cancelButton = [self findButtonWithTitle:@"Cancel"
                                            parentElement:loadingPopup];
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

- (void)saveTestReportWithName:(NSString *)name format:(NSString *)format
{
    // TODO: may be move into separate category for saved report

    XCUIElement *textField = [self findNameFieldOnSaveReportPage];
    [self enterText:name
      intoTextField:textField];

    XCUIElement *htmlCell = [self findTableViewCellWithAccessibilityId:nil
                                                 containsLabelWithText:format];
    [htmlCell tap];

    XCUIElement *saveButton = [self waitButtonWithAccessibilityId:@"Save"
                                                          timeout:kUITestsBaseTimeout];
    [saveButton tap];
}

- (XCUIElement *)findNameFieldOnSaveReportPage
{
    // TODO: replace with accessibility ids
    XCUIElement *tableView = [self.application.tables elementBoundByIndex:0];
    XCUIElement *nameCell = [tableView.cells elementBoundByIndex:0];
    XCUIElement *textField = [nameCell childrenMatchingType:XCUIElementTypeTextField].element;
    [self waitElementReady:textField
                   timeout:kUITestsBaseTimeout];
    return textField;
}

#pragma mark - Helpers

- (XCUIElement *)searchTestReportInSectionWithName:(NSString *)sectionName
{
    [self searchResourceWithName:kTestReportName
               inSectionWithName:sectionName];

    [self givenThatCellsAreVisible];

    XCUIElement *testCell = [self testReportCell];
    return testCell;
}

- (void)tryOpenTestReport
{
    [self searchTestReportInSectionWithName:@"Library"];
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
    // TODO: replace with specific element - JMLibraryPageAccessibilityId
    [self searchResourceWithName:kTestReportWithMandatoryFiltersName
    inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
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
    // TODO: replace with specific element - JMLibraryPageAccessibilityId
    [self searchResourceWithName:kTestReportWithSingleSelectedControlName
    inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
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

#pragma mark - Printing

- (void)openPrintReportPage
{
    [self openMenuActions];
    [self selectActionWithName:@"Print"];
    [self givenLoadingPopupNotVisible];
}

- (void)closePrintReportPage
{
    // verify that 'print report' page is on the screen
    XCUIElement *printNavBar = [self waitNavigationBarWithLabel:@"Printer Options"
                                                        timeout:kUITestsBaseTimeout];
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"Cancel"
                                                      parentElement:printNavBar
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

#pragma mark - Verifying

- (void)verifyThatReportInfoPageOnScreen
{
    [self verifyInfoPageOnScreenForPageWithAccessibilityId:@"JMReportInfoViewControllerAccessibilityId"];
}

- (void)verifyThatReportInfoPageContainsCorrectDataForReportWithName:(NSString *)reportName
{
    XCUIElement *infoPage = self.application.otherElements[@"JMReportInfoViewControllerAccessibilityId"];
    [self waitStaticTextWithAccessibilityId:@"Name"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"Description"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"URI"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"Type"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"Version"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"Creation Date"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"Modified Date"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
}

@end
