//
// Created by Aleksandr Dakhno on 10/4/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+InfoPage.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+Dashboard.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Folders.h"
#import "JMBaseUITestCase+Section.h"

@implementation JMBaseUITestCase (InfoPage)

#pragma mark - Info Page
- (void)openInfoPageFromCell:(XCUIElement *)cell
{
    XCUIElement *infoButton = [self waitButtonWithAccessibilityId:JMResourceCellResourceInfoButtonAccessibilityId
                                                    parentElement:cell
                                                          timeout:kUITestsBaseTimeout];
    [infoButton tap];
}

- (void)openInfoPageFromMenuActions
{
    [self openMenuActionsWithControllerAccessibilityId:nil];
    [self selectActionWithAccessibility:JMMenuActionsViewInfoActionAccessibilityId];
}

- (void)verifyInfoPageOnScreenForPageWithAccessibilityId:(NSString *)accessibilityId
{
    [self waitElementWithAccessibilityId:accessibilityId
                                 timeout:kUITestsBaseTimeout];
    
    NSArray *cellsIdentifiers = @[JMResourceInfoPageTitleLabelAccessibilityId,
                                  JMResourceInfoPageDescriptionLabelAccessibilityId,
                                  JMResourceInfoPageTypeLabelAccessibilityId,
                                  JMResourceInfoPageUriLabelAccessibilityId,
                                  JMResourceInfoPageVersionLabelAccessibilityId,
                                  JMResourceInfoPageCreationDateLabelAccessibilityId,
                                  JMResourceInfoPageModifiedDateLabelAccessibilityId];
    
    for (NSString *cellIdentifier in cellsIdentifiers) {
        NSInteger countOfCells = [self countCellsWithAccessibilityId:cellIdentifier];
        XCTAssertTrue(countOfCells == 1, @"Incorrect presenting '%@' cell", cellIdentifier);
    }
}

#pragma mark - Reports
- (void)openInfoPageForTestReportFromSectionWithAccessibilityId:(NSString *)accessibilityId
{
    [self searchResourceWithName:kJMTestLibrarySearchTextExample inSectionWithAccessibilityId:accessibilityId];
    NSArray *cellsPredicatesArray = @[[NSPredicate predicateWithFormat:@"identifier CONTAINS %@", JMResourceCollectionPageReportResourceListCellAccessibilityId],
                                      [NSPredicate predicateWithFormat:@"identifier CONTAINS %@", JMResourceCollectionPageReportResourceGridCellAccessibilityId]];
    
    NSCompoundPredicate *cellsPredicate = [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:cellsPredicatesArray];
    
    XCUIElementQuery *cellsQuery = [self.application.cells matchingPredicate:cellsPredicate];
    NSArray *allCells = cellsQuery.allElementsBoundByIndex;

    XCUIElement *resultReportCell = allCells.firstObject;
    [self openInfoPageFromCell:resultReportCell];
}

- (void)verifyThatInfoPageForTestReportHasBackButton
{
    XCUIElement *backButton = [self findBackButtonWithControllerAccessibilityId:JMReportInfoPageAccessibilityId];
    if (!backButton.exists) {
        XCTFail(@"Back button doesn't exist on 'Info' page for test report");
    }
}

- (void)verifyThatInfoPageForTestReportHasCorrectTitle
{
    XCUIElement *currentController = [self waitElementWithAccessibilityId:JMReportInfoPageAccessibilityId timeout:kUITestsBaseTimeout];
    NSString *title = currentController.label;
    
    XCUIElement *titleCell = [self findTableViewCellWithAccessibilityId:JMResourceInfoPageTitleLabelAccessibilityId containsLabelWithText:title];
    
    if (!titleCell.exists) {
        XCTFail(@"Info page for test report has incorrect title");
    }
}

#pragma mark - Dashboards
- (void)openInfoPageForTestDashboardFromSectionWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *dashboardCell = [self searchTestDashboardInSectionWithName:accessibilityId];
    [self openInfoPageFromCell:dashboardCell];
    [self verifyThatDashboardInfoPageOnScreen];
}

- (void)verifyThatInfoPageForTestDashboardHasBackButton
{
    XCUIElement *backButton = [self findBackButtonWithControllerAccessibilityId:JMDashboardInfoPageAccessibilityId];
    if (!backButton.exists) {
        XCTFail(@"Back button doesn't exist on 'Info' page for test dashboard");
    }
}

- (void)verifyThatInfoPageForTestDashboardHasCorrectTitle
{
    XCUIElement *navBar = [self findNavigationBarWithControllerAccessibilityId:kTestDashboardName];
    if (!navBar.exists) {
        XCTFail(@"Info page for test dashboard has incorrect title");
    }
}

- (void)verifyThatInfoPageForTestDashboardContainsCorrectData
{
    [self verifyThatDashboardInfoPageContainsCorrectDataForDashboardWithName:kTestDashboardName];
}

#pragma mark - Folders

- (void)openInfoPageForTestFolderFromSectionWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *folderCell = [self searchTestFolderInSectionWithName:accessibilityId];
    [self openInfoPageFromCell:folderCell];
    [self verifyThatFolderInfoPageOnScreen];
}

- (void)verifyThatInfoPageForTestFolderHasBackButton
{
    XCUIElement *backButton = [self findBackButtonWithControllerAccessibilityId:nil];
    if (!backButton.exists) {
        XCTFail(@"Back button doesn't exist on 'Info' page for test folder");
    }
}

- (void)verifyThatInfoPageForTestFolderHasCorrectTitle
{
    XCUIElement *navBar = [self findNavigationBarWithControllerAccessibilityId:kTestFolderName];
    if (!navBar.exists) {
        XCTFail(@"Info page for test folder has incorrect title");
    }
}

- (void)verifyThatInfoPageForTestFolderContainsCorrectData
{
    [self verifyThatFolderInfoPageContainsCorrectDataForFolderWithName:kTestFolderName];
}

@end
