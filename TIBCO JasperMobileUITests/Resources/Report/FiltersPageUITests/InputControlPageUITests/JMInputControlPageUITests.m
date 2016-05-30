//
//  JMInputControlPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMInputControlPageUITests.h"

@implementation JMInputControlPageUITests

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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
}

@end
