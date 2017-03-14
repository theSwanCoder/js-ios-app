/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMInputControlPageUITests.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Buttons.h"
#import "XCUIElement+Tappable.h"
#import "JMBaseUITestCase+Cells.h"

@implementation JMInputControlPageUITests

- (void)tearDown
{
    [self closeReportFiltersPage];
    [self closeTestReportPage];
    
    [super tearDown];
}

#pragma mark - JMBaseUITestCaseProtocol

- (NSInteger)testsCount
{
    return 7;
}

#pragma mark - Tests

//User should see Input Control screen
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "09. Customer Detail Report"
//    < Tap Edit Filters button
//    < Open Customer Name ID Input Control IC
//    > User should see Input Control screen
-(void)testThatUserCanSeeInputControlsScreen
{
    [self openTestReportPage];
    [self openReportFiltersPage];
    
    [self startEditFilterWithMultiItems];
    [self verifyThatInputControlsPageOnScreen];
    [self stopEditFilterWithMultiItems];
}

//Title like name of the IC
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "01. Geographic Results by Segment Report"
//    < Tap Edit Filters buton
//    < Open Product Name IC
//    > User should see title like Product Name
- (void)testThatInputControlsScreenTitleHasRightName
{
    [self openTestReportPage];
    [self openReportFiltersPage];
    
    [self startEditFilterWithMultiItems];
    [self verifyThatInputControlsPageHasCorrectTitle];
    [self stopEditFilterWithMultiItems];
}

//Subtitle for multiselect IC screen
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "01. Geographic Results by Segment Report"
//    < Tap Edit Filters button
//    < Open Product Name IC
//    > User should see subtitle like "Select one or more items"
- (void)testThatInputControlsScreenWithMultiSelecICHasSubtitle
{
    [self openTestReportPage];
    [self openReportFiltersPage];
    
    [self startEditFilterWithMultiItems];
    [self verifyThatInputControlsPageForMultiSelectHasCorrectSubtitle];
    [self stopEditFilterWithMultiItems];
}

//Subtitle for single select IC screen
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "09. Customer Detail Report"
//    < Tap Edit Filters button
//    < Open Customer Name ID Input Control IC
//    > User should see subtitle like "Select a single item"
- (void)testThatInputControlsScreenWithSingleSelecICHasSubtitle
{
    [self openTestReportWithSingleSelectedControlPage];
    [self openReportFiltersPage];
    
    [self startEditFilterWithSingleSelectedItem];
    [self verifyThatInputControlsPageForSingleSelectHasCorrectSubtitle];
    [self stopEditFilterWithSingleSelectedItem];
}

//Search result
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "01. Geographic Results by Segment Report"
//    < Tap Edit Filters button
//    < Open Product Name IC
//    < Verify searching operation
//    > User can:
//    - enter search text
//    - edit search text
//    - delete search text
//    - cancel search
//    - see result after searching
- (void)testThatSearchWorkOnInputControlsScreen
{
    [self openTestReportPage];
    [self openReportFiltersPage];
    
    [self startEditFilterWithMultiItems];
    [self trySearchCorrectValue];
    [self verifyCorrectSearchResult];
    [self stopEditFilterWithMultiItems];
}

//Error message when no search result
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "01. Geographic Results by Segment Report"
//    < Tap Edit Filters button
//    < Open Product Name IC
//    < Enter incorrect search text
//    > User should see error message "No Results." when no search result
- (void)testThatErrorMessagesAppearsForSearchWithoutResult
{
    [self openTestReportPage];
    [self openReportFiltersPage];
    
    [self startEditFilterWithMultiItems];
    [self trySearchInCorrectValue];
    [self verifyInCorrectSearchResult];
    [self stopEditFilterWithMultiItems];
}

//Back button like "Filters"
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "01. Geographic Results by Segment Report"
//    < Tap Edit Filters button
//    < Open Product Name IC
//    < Tap back button
//    > Report View screen should appear
- (void)testThatBackButtonWorkCorrectly
{
    [self openTestReportPage];
    [self openReportFiltersPage];
    
    [self startEditFilterWithMultiItems];
    [self verifyThatInputControlPageHasCorrentBackButton];
    [self stopEditFilterWithMultiItems];
}

#pragma mark - Helpers

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

- (void)trySearchCorrectValue
{
    //Search Values
    [self searchInMultiSelectedInputControlWithText:@"true"]; // We don't have translation for this string
}

- (void)trySearchInCorrectValue
{
    [self searchInMultiSelectedInputControlWithText:@"incorrect text value"]; // We don't have translation for this string
}

#pragma mark - Verifying

- (void)verifyThatInputControlsPageOnScreen
{
    [self verifyThatInputControlsPageHasCorrectTitle];
}

- (void)verifyThatInputControlsPageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:@"Low Fat" // We don't have translation for this string
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatInputControlsPageForMultiSelectHasCorrectSubtitle
{
    [self verifyStaticTextExistsWithText:JMLocalizedString(@"report_viewer_options_multiselect_titlelabel_title")];
}

- (void)verifyThatInputControlsPageForSingleSelectHasCorrectSubtitle
{
    [self verifyStaticTextExistsWithText:JMLocalizedString(@"report_viewer_options_singleselect_titlelabel_title")];
}

- (void)verifyCorrectSearchResult
{
    [self findTableViewCellWithAccessibilityId:nil
                         containsLabelWithText:@"true"]; // We don't have translation for this string
}

- (void)verifyInCorrectSearchResult
{
    [self verifyStaticTextExistsWithText:JMLocalizedString(@"resources_noresults_msg")];
}

- (void)verifyThatInputControlPageHasCorrentBackButton
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:@"Low Fat" // We don't have translation for this string
                                                   timeout:kUITestsBaseTimeout];
    [self verifyButtonExistWithText:JMLocalizedString(@"action_title_edit_filters")
                      parentElement:navBar];
}

#pragma mark - Helpers

- (void)verifyStaticTextExistsWithText:(NSString *)text
{
    XCUIElement *staticText = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                       text:text
                                                    timeout:kUITestsBaseTimeout];
    if (!staticText.exists) {
        XCTFail(@"Static text wasn't found");
    }
}

@end
