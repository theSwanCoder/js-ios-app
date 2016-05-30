//
//  JMSavedItemPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMSavedItemPageUITests.h"

@implementation JMSavedItemPageUITests

#pragma mark - Tests

//User should see the saved report as HTML
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved report as HTML
//    > User should see Saved Report View Screen
- (void)testThatUserCanSeeSavedItemAsHTML
{
//    XCTFail(@"Not implemented tests");
}

//User should see the saved report as PDF
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved report as PDF
//    > User should see Saved Report View Screen
- (void)testThatUserCanSeeSavedItemAsPDF
{
//    XCTFail(@"Not implemented tests");
}

//Back button like "Saved Items"
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved report
//    < Tap back button
//    > Saved Items screen should appears
- (void)testThatBackButtonHasCorrectTitle
{
//    XCTFail(@"Not implemented tests");
}

//Saved Report View title
//        < Open the Left Panel
//        < Tap on the Saved Items button
//        < Open the saved report
//        > User should see title like name of the saved report
- (void)testThatPageHasCorrectTitle
{
//    XCTFail(@"Not implemented tests");
}

//Favorite button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Add saved item to favorites
//    < Remove saved item from favorites
//    > Star should be filled after adding the item to favorites
//    > Star should be empty after removing the item from favorites
- (void)testThatFavoriteButtonWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Cancel deleting
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved file
//    < Tap Delete button
//    < Tap Cancel button
//    > Report isn't deleted
- (void)testThatDeletingCanBeCanceled
{
//    XCTFail(@"Not implemented tests");
}

//Cancel rename
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved file
//    < Tap Rename button
//    < Enter correct report name
//    < Tap "Cancel" button
//    > Report isn't renamed
- (void)testThatRenamingCanBeCanceled
{
//    XCTFail(@"Not implemented tests");
}

//Rename the saved file
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved file
//    < Tap Rename button
//    < Enter new report name and tap "OK" button
//    > Rename report dialog should appear
//    > Rename report dialog should disappear and Saved Item View screen should be displayed
- (void)testThatRenameWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Try to rename the saved file with empty name
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved file
//    < Tap Rename button
//    < Report name should be empty
//    < Tap "OK" button
//    > "OK" button disabled. Report is not saved.
- (void)testThatRenameNotWorkWithEmptyName
{
//    XCTFail(@"Not implemented tests");
}

//Try to rename the saved file if saved file name includes only spaces
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved file
//    < Tap Save button
//    < Enter some spaces in "Report Name" field
//    < Tap "OK" button
//    > "OK" button disabled. Report is not saved.
- (void)testThatRenameNotWorkWithSpacesInName
{
//    XCTFail(@"Not implemented tests");
}

//Try to rename the saved file if report name already exist
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved file
//    < Tap Rename button
//    < Enter the report name which already exist (output format is same one) and tap "OK" button
//    > Report is not saved. User should see error message "This name has been already taken, please choose different name"
- (void)testThatRenameNotWorkForExistingName
{
//    XCTFail(@"Not implemented tests");
}

//Rename the saved item with same name in different output formats
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved file
//    < Tap Rename button
//    < Enter the report name which already exist (output formats are different) and tap "OK" button
//    > Report is saved.
- (void)testThatRenameWorkForExistingNameButOtherFormat
{
//    XCTFail(@"Not implemented tests");
}

//Info button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved report
//    < Tap Info button on the Saved Report View screen
//    > Info dialog (screen for iPhone) about the report should appear
- (void)testThatInfoButtonWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Zoom on Report View screen
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved report
//    < Increase the zoom
//    < Decrease the zoom
//    < Verify that saved report is not scalled if previous saved report was scalled
//    > Saved report should be bigger
//    > Saved report should be smaller
//    > Report shouldn't be scalled
- (void)testThatZoomWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

@end
