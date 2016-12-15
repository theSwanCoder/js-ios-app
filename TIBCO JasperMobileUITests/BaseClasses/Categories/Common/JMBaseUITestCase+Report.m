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
#import "XCUIElement+Tappable.h"

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
    [self givenThatReportCellsOnScreenInSectionWithName:JMLocalizedString(@"menuitem_library_label")];

    [self tryOpenTestReportWithMandatoryFilters];
    // We can have two times when loading up and down
    // first time loading 'report info' and second one - loading report
    [self givenLoadingPopupNotVisible];
    [self givenLoadingPopupNotVisible];
}

- (void)openTestReportWithSingleSelectedControlPage
{
    [self givenThatReportCellsOnScreenInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    
    [self tryOpenTestReportWithSingleSelectedControl];
    // We can have two times when loading up and down
    // first time loading 'report info' and second one - loading report
    [self givenLoadingPopupNotVisible];
    [self givenLoadingPopupNotVisible];
}

- (void)openTestReportPageWithWaitingFinish:(BOOL)waitingFinish
{
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
    // TODO: the same code is for dashboard - may be make it common?
    XCUIElement *loadingPopup = [self waitElementMatchingType:XCUIElementTypeOther
                                                   identifier:@"JMCancelRequestPopupAccessibilityId"
                                                      timeout:0];
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
    [htmlCell tapByWaitingHittable];

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
    XCUIElement *testCell = [self searchTestReportInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [testCell tapByWaitingHittable];
}

- (XCUIElement *)searchTestReportInSectionWithName:(NSString *)sectionName
{
    [self performSearchResourceWithName:kTestReportName
                      inSectionWithName:sectionName];

    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];

    XCUIElement *testCell = [self testReportCell];
    return testCell;
}

- (XCUIElement *)testReportCell
{
    XCUIElement *testCell = [self waitCollectionViewCellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                           containsLabelWithAccessibilityId:@"JMResourceCellResourceNameLabelAccessibilityId"
                                                                  labelText:kTestReportName
                                                                    timeout:kUITestsElementAvailableTimeout];
    return testCell;
}

- (void)tryOpenTestReportWithMandatoryFilters
{
    [self searchTestReportWithMandatoryFilters];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];

    XCUIElement *testCell = [self testReportWithMandatoryFiltersCell];
    [testCell tapByWaitingHittable];
}

- (void)searchTestReportWithMandatoryFilters
{
    // TODO: replace with specific element - JMLibraryPageAccessibilityId
    [self performSearchResourceWithName:kTestReportWithMandatoryFiltersName
           inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
}

- (XCUIElement *)testReportWithMandatoryFiltersCell
{
    XCUIElement *testCell = [self waitCollectionViewCellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                           containsLabelWithAccessibilityId:@"JMResourceCellResourceNameLabelAccessibilityId"
                                                                  labelText:kTestReportWithMandatoryFiltersName
                                                                    timeout:kUITestsElementAvailableTimeout];
    return testCell;
}

- (void)tryOpenTestReportWithSingleSelectedControl
{
    [self searchTestReportWithSingleSelectedControl];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
    
    XCUIElement *testCell = [self testReportWithSingleSelectedControl];
    [testCell tapByWaitingHittable];
}

- (void)searchTestReportWithSingleSelectedControl
{
    // TODO: replace with specific element - JMLibraryPageAccessibilityId
    [self performSearchResourceWithName:kTestReportWithSingleSelectedControlName
           inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
}

- (XCUIElement *)testReportWithSingleSelectedControl
{
    XCUIElement *testCell = [self waitCollectionViewCellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                           containsLabelWithAccessibilityId:@"JMResourceCellResourceNameLabelAccessibilityId"
                                                                  labelText:kTestReportWithSingleSelectedControlName
                                                                    timeout:kUITestsElementAvailableTimeout];
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

- (void)givenThatReportCellsOnScreenInSectionWithName:(NSString *)sectionName
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self selectFilterBy:@"Reports"
      inSectionWithTitle:sectionName];
    [self givenThatCollectionViewContainsListOfCellsInSectionWithName:sectionName];
}

@end
