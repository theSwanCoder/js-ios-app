//
//  JMSavedItemsPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMSavedItemsPageUITests.h"

@implementation JMSavedItemsPageUITests

#pragma mark - Tests

//User should see Saved Items screen
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > User should see Saved Items screen
- (void)testThatUserCanSeeSavedItemsPage
{
//    XCTFail(@"Not implemented tests");
}

//Left Panel button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > User should see Left Panel button on the Saved Items screen
- (void)testThatMenuButtonWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Saved Items title
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > User should see title like "Saved Items"
- (void)testThatPageHasCorrectTitle
{
//    XCTFail(@"Not implemented tests");
}

//Search result
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Verify searching operation
//    > User can:
//    - enter search text
//    - edit search text
//    - delete search text
//    - cancel search
//    - see result after searching
- (void)testThatSearchWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Error message when no search result
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Enter incorrect search text
//    > User can see error message when no search result
- (void)testThatCorrectMessageAppearsInCaseSearchWithoutResult
{
//    XCTFail(@"Not implemented tests");
}

//Viev type button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Switch View Type to grid
//    < Switch View Type to list
//    < Verify that view type is saved when user change one and leave Saved Items page
//    > User can see items as grid (user can see icon and label of item) and View Type button should be switched
//    > User can see items as list (user can see icon, label and description of item) and View Type button should be switched
- (void)testThatViewTypeButtonWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Sorting button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Tap Sorting button
//    < Select sorting by Name
//    < Select sorting by Creation Date
//    < Select sorting by Modified Date
//    < Verify that sorting options don't save when user leave Saved Items screen
//    > Sorting dialog should appear
//    > User can sorted by Name
//    > User can sorted by Creation Date
//    > User can sorted by Modified Date
- (void)testThatSortButtonWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Filter button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Tap Filter button
//    < Select filter by All
//    < Select filter by HTML
//    < Select filter by PDF
//    < Select filter by XLS
//    < Verify that filter options don't save when user leave Saved Items screen
//    > Filter dialog should appear
//    > User can see all items
//    > User can see only HTML-files
//    > User can see only PDF-files
//    > User can see only XLS-files
- (void)testThatFilterButtonWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Appropriate icon for HTML-file
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save icon
//    < Enter correct report name
//    < Choose Output Format as HTML
//    < Tap Save button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > User should see Appropriate icon for HTML-file
- (void)testThatHTMLFileHasCorrectIcon
{
//    XCTFail(@"Not implemented tests");
}

//File extension for HTML-file
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save icon
//    < Enter correct report name
//    < Choose Output Format as HTML
//    < Tap Save button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > User should see file extension for HTML-file as .html
- (void)testThatHTMLFileHasCorrectFormat
{
//    XCTFail(@"Not implemented tests");
}

//Appropriate icon for PDF-file
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save icon
//    < Enter correct report name
//    < Choose Output Format as PDF
//    < Tap Save button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > User should see Appropriate icon for PDF-file
- (void)testThatPDFfileHasCorrectIcon
{
//    XCTFail(@"Not implemented tests");
}

//File extension for PDF-file
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save icon
//    < Enter correct report name
//    < Choose Output Format as PDF
//    < Tap Save button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > User should see file extension for PDF-file as .pdf
- (void)testThatPDFfileHasCorrectFormat
{
//    XCTFail(@"Not implemented tests");
}

//Pull down to refresh all items
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Pull down to refresh
//    > Saved Items screen should refresh
- (void)testThatPullDownToRefreshWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Scrolling of the list/grid
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Scroll the list
//    < Scroll the grid
//    > Scroll should work as expected
- (void)testThatScrollingWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//User should see only saved files which he/she saved they
//    < Open the Left Panel
//    < Tap on the Settings button
//    < Tap on current active server's name
//    < Tap on any server connection
//    < Login as joeuser
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save icon
//    < Save the report
//    < Open the Left Panel
//    < Tap on the Settings button
//    < Tap on current active server's name
//    < Tap on any server connection
//    < Login as jasperadmin
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > Jasperadmin shouldn't see saved files which joeuser saved they
- (void)testThatSavedItemsForActiveAccountVisible
{
//    XCTFail(@"Not implemented tests");
}

@end
