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
#import "JMBaseUITestCase+TextFields.h"
#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+Search.h"

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

    [self tryBackToPreviousPage];
}

- (void)openTestReportWithMandatoryFiltersPage
{
    [self givenThatReportCellsOnScreen];

    [self tryOpenTestReportWithMandatoryFilters];
    // We can have two times when loading up and down
    // first time loading 'report info' and second one - loading report
    [self givenLoadingPopupNotVisible];
}

- (void)openTestReportWithSingleSelectedControlPage
{
    [self givenThatReportCellsOnScreen];
    
    [self tryOpenTestReportWithSingleSelectedControl];
    // We can have two times when loading up and down
    // first time loading 'report info' and second one - loading report
    [self givenLoadingPopupNotVisible];
}

- (void)openTestReportPageWithWaitingFinish:(BOOL)waitingFinish
{
    [self tryOpenTestReport];

    if (waitingFinish) {
        // We can have two times when loading up and down
        // first time loading 'report info' and second one - loading report
        [self givenLoadingPopupNotVisible];
    }
}

- (void)closeTestReportPage
{
    [self tryBackToPreviousPage];
}

- (void)cancelOpeningTestReportPage
{
    // TODO: the same code is for dashboard - may be make it common?
    XCUIElement *loadingPopup = [self waitElementMatchingType:XCUIElementTypeOther
                                                   identifier:@"JMCancelRequestPopupAccessibilityId"
                                                      timeout:kUITestsBaseTimeout];;
    [self tapButtonWithText:JMLocalizedString(@"dialog_button_cancel")
              parentElement:loadingPopup
                shouldCheck:YES];
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

- (void)openSavingReportPage
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

    // Enter name of saving item
    XCUIElement *textField = [self findNameFieldOnSaveReportPage];
    [self enterText:name
      intoTextField:textField];

    // Select format
    XCUIElement *htmlCell = [self findTableViewCellWithAccessibilityId:nil
                                                 containsLabelWithText:format];
    [htmlCell tap];

    // Perform saving
    [self tapButtonWithText:@"Save"
              parentElement:nil
                shouldCheck:YES];
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

- (void)tryOpenTestReport
{
    XCUIElement *testCell = [self searchTestReportInSectionWithName:@"Library"];
    [testCell tap];
}

- (XCUIElement *)searchTestReportInSectionWithName:(NSString *)sectionName
{
    [self performSearchResourceWithName:kTestReportName
                      inSectionWithName:sectionName];

    // TODO: replace with real check 'loading' message
    sleep(1);

    [self verifyThatCollectionViewContainsCells];

    XCUIElement *testCell = [self testReportCell];
    return testCell;
}

- (XCUIElement *)testReportCell
{
    XCUIElement *testCell = [self findCollectionViewCellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                           containsLabelWithAccessibilityId:@"JMResourceCellResourceNameLabelAccessibilityId"
                                                                  labelText:kTestReportName];
    if (!testCell) {
        XCTFail(@"Test cell wasn't found");
    }
    return testCell;
}

- (void)tryOpenTestReportWithMandatoryFilters
{
    [self searchTestReportWithMandatoryFilters];
    [self verifyThatCollectionViewContainsCells];

    XCUIElement *testCell = [self testReportWithMandatoryFiltersCell];
    [testCell tap];
}

- (void)searchTestReportWithMandatoryFilters
{
    // TODO: replace with specific element - JMLibraryPageAccessibilityId
    [self performSearchResourceWithName:kTestReportWithMandatoryFiltersName
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
    [self verifyThatCollectionViewContainsCells];
    
    XCUIElement *testCell = [self testReportWithSingleSelectedControl];
    [testCell tap];
}

- (void)searchTestReportWithSingleSelectedControl
{
    // TODO: replace with specific element - JMLibraryPageAccessibilityId
    [self performSearchResourceWithName:kTestReportWithSingleSelectedControlName
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
    [self tapCancelButtonOnNavBarWithTitle:@"Printer Options"];
}

#pragma mark - Verifying

- (void)verifyThatReportInfoPageOnScreen
{
    [self verifyInfoPageOnScreenForPageWithAccessibilityId:@"JMReportInfoViewControllerAccessibilityId"];
}

- (void)verifyThatReportInfoPageContainsCorrectDataForReportWithName:(NSString *)reportName
{
    XCUIElement *infoPage = self.application.otherElements[@"JMReportInfoViewControllerAccessibilityId"];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Name"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Description"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"URI"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Type"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Version"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Creation Date"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Modified Date"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
}

- (void)givenThatReportCellsOnScreen
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self selectFilterBy:@"Reports"
      inSectionWithTitle:@"Library"];
    [self givenThatCollectionViewContainsListOfCellsInSectionWithName:@"Library"];
}

@end
