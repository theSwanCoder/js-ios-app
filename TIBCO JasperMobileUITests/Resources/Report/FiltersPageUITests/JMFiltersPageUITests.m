//
//  JMFiltersPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMFiltersPageUITests.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Buttons.h"
#import "XCUIElement+Tappable.h"
#import "JMBaseUITestCase+Cells.h"
#import "JMBaseUITestCase+Alerts.h"

@implementation JMFiltersPageUITests

#pragma mark - JMBaseUITestCaseProtocol

- (NSInteger)testsCount
{
    return 9;
}

#pragma mark - Tests

//User should see Filters screen
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "01. Geographic Results by Segment Report"
//    < Tap Edit Filters button
//    > User should see Filters screen
- (void)testThatUserCanSeeFiltersPage
{
    [self openTestReportPage];
    [self openReportFiltersPage];
    
    [self verifyThatReportFiltersPageOnScreen];

    [self closeReportFiltersPage];
    [self closeTestReportPage];
}

//Filters title
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "01. Geographic Results by Segment Report"
//    < Tap Edit Filters button
//    > User should see title like "Filters"
- (void)testThatFiltersPageHasCorrectTitle
{
    [self openTestReportPage];
    [self openReportFiltersPage];
    
    [self verifyThatReportFiltersPageHasCorrectTitle];

    [self closeReportFiltersPage];
    [self closeTestReportPage];
}

//Run Report button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "01. Geographic Results by Segment Report"
//    < Tap Edit Filters button
//    < Tap Run report button
//    > Report View screen should appear
- (void)testThatUserCanApplyFilters
{
    [self openTestReportPage];
    [self openReportFiltersPage];

    XCUIElement *errorAlert = [self findAlertWithTitle:@"JSErrorDomain"];
    if (errorAlert.exists) {
        XCTFail(@"Error of fetching filters for report");
    } else {
        [self tapButtonWithText:JMLocalizedString(@"dialog_button_run_report")
                  parentElement:nil
                    shouldCheck:YES];
        [self givenLoadingPopupNotVisible];
    }

    [self closeTestReportPage];
}

//Back button like title of previous screen
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "01. Geographic Results by Segment Report"
//    < Tap Edit Filters button
//    < Tap back button
//    > Report View screen should appears
- (void)testThatBackButtonWorkCorreclty
{
    [self openTestReportPage];
    [self openReportFiltersPage];
    
    [self verifyThatFiltersPageHasCorrentBackButton];

    [self closeReportFiltersPage];
    [self closeTestReportPage];
}

//Mandatory IC
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "06. Profit Detail Report"
//    < Tap Edit Filters button
//    < Run report if mandatory IC is empty
//    > User should see error message "This filed is mandatory so you must enter data."
- (void)testThatMandatoryICWorkCorrectly
{
    [self openTestReportWithMandatoryFiltersPage];
    [self openReportFiltersPage];

    [self verifyMandatoryCellNotContainsErrorMessage];
    
    [self startEditMandatoryFilter];
    [self unmarkAllControlItemsForMandatoryFilter];
    [self stopEditMandatoryFilter];

    [self verifyMandatoryCellContainsErrorMessage];

    [self closeReportFiltersPage];
    [self closeTestReportPage];
}

//Multiselect IC
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "01. Geographic Results by Segment Report"
//    < Tap Edit Filters button
//    < Open Product Name IC
//    > Should appear multiselect IC screen. Verify that user can select/unselect some items.
- (void)testThatMultiselectICWorkCorreclty
{
    [self openTestReportPage];
    [self openReportFiltersPage];

    [self startEditFilterWithMultiItems];

    [self markTestControlItemForFilterWithMultipleSelectedItems];
    [self unmarkTestControlItemForFilterWithMultipleSelectedItems];

    [self stopEditFilterWithMultiItems];

    [self closeReportFiltersPage];
    [self closeTestReportPage];
}

//Single select IC
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "09. Customer Detail Report"
//    < Tap Edit Filters button
//    < Open Customer Name ID Input Control
//    > Should appear single select IC screen. Verify that user can select only one item.
- (void)testThatSingleSelectICWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
    [self openTestReportWithSingleSelectedControlPage];
    [self openReportFiltersPage];
    
    [self verifyThatReportFiltersPageOnScreen];
    [self startEditFilterWithSingleSelectedItem];

    [self markTestControlItemForFilterWithSingleSelectedItems];    
    [self verifyThatReportFiltersPageOnScreen];

    [self closeReportFiltersPage];
    [self closeTestReportPage];
}

//Text IC
//    < Import "02_AdditionalResourcesForTesting" file on JSR
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "Ad Hoc View All filters Report"
//    < Enter text to column_string does not contain IC
//    < Edit text in column_string does not contain IC
//    < Delete text in column_string does not contain IC
//    > User can enter text
//    > User can edit text
//    > User can delete text
- (void)testThatTextICWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Incorrect IC
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "01. Geographic Results by Segment Report"
//    < Tap Edit Filters
//    < Enter 50 to "Store Sales 2013 is greater than:"
//    < Tap Run Report button
//    > User should see message "Report is empty"
- (void)testThatReportShowsCorrectMessageForIncorrectIC
{
//    XCTFail(@"Not implemented tests");    
}

#pragma mark - Helpers

- (void)startEditMandatoryFilter
{
    XCUIElement *cellWithMandatoryFilter = [self findTableViewCellWithAccessibilityId:nil
                                                                containsLabelWithText:@"* ProductFamily"]; // We don't have translation for this string
    [cellWithMandatoryFilter tapByWaitingHittable];
}

- (void)stopEditMandatoryFilter
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:@"ProductFamily" // We don't have translation for this string
                                                   timeout:kUITestsBaseTimeout];
    [self tapButtonWithText:JMLocalizedString(@"action_title_edit_filters")
              parentElement:navBar
                shouldCheck:YES];
}

- (void)unmarkAllControlItemsForMandatoryFilter
{
    XCUIElement *drinkItem = [self findTableViewCellWithAccessibilityId:nil
                                                  containsLabelWithText:@"Drink"]; // We don't have translation for this string
    [drinkItem tapByWaitingHittable];

    XCUIElement *foodItem = [self findTableViewCellWithAccessibilityId:nil
                                                 containsLabelWithText:@"Food"]; // We don't have translation for this string
    [foodItem tapByWaitingHittable];

    XCUIElement *nonConsumableItem = [self findTableViewCellWithAccessibilityId:nil
                                                          containsLabelWithText:@"Non-Consumable"]; // We don't have translation for this string
    [nonConsumableItem tapByWaitingHittable];
}

- (void)startEditFilterWithMultiItems
{
    XCUIElement *cellWithMandatoryFilter = [self findTableViewCellWithAccessibilityId:nil
                                                                containsLabelWithText:@"Low Fat"]; // We don't have translation for this string
    [cellWithMandatoryFilter tapByWaitingHittable];
}

- (void)stopEditFilterWithMultiItems
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:@"Low Fat" // We don't have translation for this string
                                                   timeout:kUITestsBaseTimeout];
    [self tapButtonWithText:JMLocalizedString(@"action_title_edit_filters")
              parentElement:navBar
                shouldCheck:YES];
}

- (void)markTestControlItemForFilterWithMultipleSelectedItems
{
    XCUIElement *trueItem = [self findTableViewCellWithAccessibilityId:nil
                                                  containsLabelWithText:@"true"]; // We don't have translation for this string
    [trueItem tapByWaitingHittable];
}

- (void)unmarkTestControlItemForFilterWithMultipleSelectedItems
{
    XCUIElement *trueItem = [self findTableViewCellWithAccessibilityId:nil
                                                  containsLabelWithText:@"true"]; // We don't have translation for this string
    [trueItem tapByWaitingHittable];
}

- (void)startEditFilterWithSingleSelectedItem
{
    XCUIElement *cell = [self findTableViewCellWithAccessibilityId:nil
                                             containsLabelWithText:@"Country"]; // We don't have translation for this string
    [cell tapByWaitingHittable];
}

- (void)stopEditFilterWithSingleSelectedItem
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:@"Country" // We don't have translation for this string
                                                   timeout:kUITestsBaseTimeout];
    [self tapButtonWithText:JMLocalizedString(@"action_title_edit_filters")
              parentElement:navBar
                shouldCheck:YES];
}

- (void)markTestControlItemForFilterWithSingleSelectedItems
{
    XCUIElement *cell = [self findTableViewCellWithAccessibilityId:nil
                                             containsLabelWithText:@"Mexico"]; // We don't have translation for this string
    [cell tapByWaitingHittable];
}

- (void)startEditTestTextField
{
    XCUIElement *cell = [self findTableViewCellWithAccessibilityId:nil
                                             containsLabelWithText:@"Store Sales 2013 is greater than"]; // We don't have translation for this string
    XCUIElement *textField = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                      text:@"19" // We don't have translation for this string
                                             parentElement:cell
                                                   timeout:kUITestsBaseTimeout];
    [textField tapByWaitingHittable];

}

#pragma mark - Verifying

- (void)verifyThatReportFiltersPageOnScreen
{
    XCUIElement *element = [self waitElementMatchingType:XCUIElementTypeOther
                                              identifier:@"JMInputControlsViewControllerAccessibilityIdentifier"
                                                 timeout:kUITestsBaseTimeout];
    if (!element.exists) {
        XCTFail(@"Element wasn't found");
    }
}

- (void)verifyThatReportFiltersPageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:JMLocalizedString(@"action_title_edit_filters")
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatFiltersPageHasCorrentBackButton
{
    [self verifyBackButtonExistWithAlternativeTitle:nil
                                  onNavBarWithTitle:JMLocalizedString(@"report_viewer_options_title")];
}

- (void)verifyMandatoryCellContainsErrorMessage
{
    XCUIElement *cellWithMandatoryFilter = [self findTableViewCellWithAccessibilityId:nil
                                                                containsLabelWithText:@"This field is mandatory so you must enter data."];
    XCTAssert(cellWithMandatoryFilter, @"Cell should contain error message");
}

- (void)verifyMandatoryCellNotContainsErrorMessage
{
    XCUIElement *cellWithMandatoryFilter = [self findTableViewCellWithAccessibilityId:nil
                                                                containsLabelWithText:@"This filed is mandatory so you must enter data."];
    XCTAssertNil(cellWithMandatoryFilter, @"Cell should not contain error message");
}

@end
