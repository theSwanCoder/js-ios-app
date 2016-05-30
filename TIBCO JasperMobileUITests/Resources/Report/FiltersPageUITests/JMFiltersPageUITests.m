//
//  JMFiltersPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMFiltersPageUITests.h"

@implementation JMFiltersPageUITests

#pragma mark - Tests

//User should see Filters screen
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "01. Geographic Results by Segment Report"
//    < Tap Edit Filters button
//    > User should see Filters screen
- (void)testThatUserCanSeeFiltersPage
{
//    XCTFail(@"Not implemented tests");
}

//Filters title
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run "01. Geographic Results by Segment Report"
//    < Tap Edit Filters button
//    > User should see title like "Filters"
- (void)testThatFiltersPageHasTitleLikeReportName
{
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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

@end
