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

@implementation JMFiltersPageUITests

- (void)tearDown
{
    [self closeReportFiltersPage];
    [self closeTestReportPage];

    [super tearDown];
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
    
    XCUIElement *runButton = [self waitButtonWithAccessibilityId:@"Run Report"
                                                         timeout:kUITestsBaseTimeout];
    [runButton tap];
    [self givenLoadingPopupNotVisible];
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
                                                                containsLabelWithText:@"* ProductFamily"];
    [cellWithMandatoryFilter tap];
}

- (void)stopEditMandatoryFilter
{
    XCUIElement *backButton = [self waitBackButtonWithAccessibilityId:@"Filters"
                                                    onNavBarWithLabel:@"ProductFamily"
                                                              timeout:kUITestsBaseTimeout];
    [backButton tap];
}

- (void)unmarkAllControlItemsForMandatoryFilter
{
    XCUIElement *drinkItem = [self findTableViewCellWithAccessibilityId:nil
                                                  containsLabelWithText:@"Drink"];
    [drinkItem tap];

    XCUIElement *foodItem = [self findTableViewCellWithAccessibilityId:nil
                                                 containsLabelWithText:@"Food"];
    [foodItem tap];

    XCUIElement *nonConsumableItem = [self findTableViewCellWithAccessibilityId:nil
                                                          containsLabelWithText:@"Non-Consumable"];
    [nonConsumableItem tap];
}

- (void)startEditFilterWithMultiItems
{
    XCUIElement *cellWithMandatoryFilter = [self findTableViewCellWithAccessibilityId:nil
                                                                containsLabelWithText:@"Low Fat"];
    [cellWithMandatoryFilter tap];
}

- (void)stopEditFilterWithMultiItems
{
    XCUIElement *backButton = [self waitBackButtonWithAccessibilityId:@"Filters"
                                                    onNavBarWithLabel:@"Low Fat"
                                                              timeout:kUITestsBaseTimeout];
    [backButton tap];
}

- (void)markTestControlItemForFilterWithMultipleSelectedItems
{
    XCUIElement *trueItem = [self findTableViewCellWithAccessibilityId:nil
                                                  containsLabelWithText:@"true"];
    [trueItem tap];
}

- (void)unmarkTestControlItemForFilterWithMultipleSelectedItems
{
    XCUIElement *trueItem = [self findTableViewCellWithAccessibilityId:nil
                                                  containsLabelWithText:@"true"];;
    [trueItem tap];
}

- (void)startEditFilterWithSingleSelectedItem
{
    XCUIElement *cell = [self findTableViewCellWithAccessibilityId:nil
                                             containsLabelWithText:@"Country"];
    [cell tap];
}

- (void)stopEditFilterWithSingleSelectedItem
{
    XCUIElement *backButton = [self waitBackButtonWithAccessibilityId:@"Filters"
                                                    onNavBarWithLabel:@"Country"
                                                              timeout:kUITestsBaseTimeout];
    [backButton tap];
}

- (void)markTestControlItemForFilterWithSingleSelectedItems
{
    XCUIElement *cell = [self findTableViewCellWithAccessibilityId:nil
                                             containsLabelWithText:@"Mexico"];
    [cell tap];
}

- (void)startEditTestTextField
{
    XCUIElement *cell = [self findTableViewCellWithAccessibilityId:nil
                                             containsLabelWithText:@"Store Sales 2013 is greater than"];
    XCUIElement *textField = [self waitStaticTextWithAccessibilityId:@"19" 
                                                       parentElement:cell 
                                                             timeout:kUITestsBaseTimeout];
    [textField tap];
}

#pragma mark - Verifying

- (void)verifyThatReportFiltersPageOnScreen
{
    [self waitElementWithAccessibilityId:@"JMInputControlsViewControllerAccessibilityIdentifier"
                                 timeout:kUITestsBaseTimeout];
}

- (void)verifyThatReportFiltersPageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:@"Filters"
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatFiltersPageHasCorrentBackButton
{
    [self waitBackButtonWithAccessibilityId:@"Back"
                          onNavBarWithLabel:@"Filters"
                                    timeout:kUITestsBaseTimeout];
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
