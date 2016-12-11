//
//  JMSavedItemPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMSavedItemPageUITests.h"
#import "JMBaseUITestCase+SavedItems.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+InfoPage.h"
#import "JMBaseUITestCase+TextFields.h"
#import "JMBaseUITestCase+Buttons.h"

@implementation JMSavedItemPageUITests

#pragma mark - Tests

//User should see the saved report as HTML
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved report as HTML
//    > User should see Saved Report View Screen
- (void)testThatUserCanSeeSavedItemAsHTML
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];

    [self openTestSavedItemInHTMLFormat];
    [self closeTestSavedItem];
    
    [self deleteTestReportInHTMLFormat];
}

//User should see the saved report as PDF
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved report as PDF
//    > User should see Saved Report View Screen
- (void)testThatUserCanSeeSavedItemAsPDF
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInPDFFormat];
    
    [self openTestSavedItemInPDFFormat];
    [self closeTestSavedItem];
    
    [self deleteTestReportInPDFFormat];
}

//Back button like "Saved Items"
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved report
//    < Tap back button
//    > Saved Items screen should appears
- (void)testThatBackButtonHasCorrectTitle
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    
    [self openTestSavedItemInHTMLFormat];
    [self verifyThatBackButtonHasCorrectTitle];
    [self closeTestSavedItem];
    
    [self deleteTestReportInHTMLFormat];
}

//Saved Report View title
//        < Open the Left Panel
//        < Tap on the Saved Items button
//        < Open the saved report
//        > User should see title like name of the saved report
- (void)testThatPageHasCorrectTitle
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    
    [self openTestSavedItemInHTMLFormat];
    [self verifyThatSavedItemPageHasCorrectTitle];
    [self closeTestSavedItem];
    
    [self deleteTestReportInHTMLFormat];
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
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    
    [self openTestSavedItemInHTMLFormat];

    [self markTestSavedItemAsFavoriteFromViewerPage];
    [self unmarkTestSavedItemAsFavoriteFromViewerPage];
    
    [self closeTestSavedItem];
    
    [self deleteTestReportInHTMLFormat];
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
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self openTestSavedItemInHTMLFormat];

    [self openMenuActionsOnNavBarWithLabel:kTestReportName];
    [self selectActionWithName:@"Delete"];
    [self cancelDeletingAction];

    [self closeTestSavedItem];
    [self deleteTestReportInHTMLFormat];
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
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self openTestSavedItemInHTMLFormat];
    
    [self openMenuActionsOnNavBarWithLabel:kTestReportName];
    [self selectActionWithName:@"Rename"];
    [self cancelRenamingAction];
    
    [self closeTestSavedItem];
    [self deleteTestReportInHTMLFormat];
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
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self openTestSavedItemInHTMLFormat];
    
    [self openMenuActionsOnNavBarWithLabel:kTestReportName];
    [self selectActionWithName:@"Rename"];
    [self performRenameAction];
    
    [self closeTestSavedItem];
    [self deleteTestReportInHTMLFormat];
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
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self openTestSavedItemInHTMLFormat];
    
    [self openMenuActionsOnNavBarWithLabel:kTestReportName];
    [self selectActionWithName:@"Rename"];
    [self performRenameActionWithEmptyName];
    
    [self closeTestSavedItem];
    [self deleteTestReportInHTMLFormat];
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
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self openTestSavedItemInHTMLFormat];
    
    [self openMenuActionsOnNavBarWithLabel:kTestReportName];
    [self selectActionWithName:@"Rename"];
    [self performRenameActionWithSpacesInName];
    
    [self closeTestSavedItem];
    [self deleteTestReportInHTMLFormat];
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
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self openTestSavedItemInHTMLFormat];
    
    [self openMenuActionsOnNavBarWithLabel:kTestReportName];
    [self selectActionWithName:@"Rename"];
    [self performRenameActionWithTheSameName];
    
    [self closeTestSavedItem];
    [self deleteTestReportInHTMLFormat];
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
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    
    [self showInfoPageTestSavedItemFromSavedItemsSection];
    [self verifyThatInfoPageOnScreen];
    [self closeInfoPageTestSavedItemFromSavedItemsSection];
    
    [self deleteTestReportInHTMLFormat];
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
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self openTestSavedItemInHTMLFormat];
    
    XCUIElement *webView = [self.application.webViews elementBoundByIndex:0];
    [self waitElementReady:webView
                   timeout:kUITestsBaseTimeout];
    [webView pinchWithScale:2
                   velocity:1];
    sleep(kUITestsElementAvailableTimeout);
    
    [self closeTestSavedItem];
    [self deleteTestReportInHTMLFormat];
}

#pragma mark - Helpers

- (void)cancelDeletingAction
{
    [self tapCancelButtonOnNavBarWithTitle:nil];
}

- (void)cancelRenamingAction
{
    [self tapCancelButtonOnNavBarWithTitle:nil];
}

- (void)performRenameAction
{
    XCUIElement *textField = [self.application.textFields elementBoundByIndex:0];
    [self waitElementReady:textField
                   timeout:kUITestsBaseTimeout];
    [textField typeText:@"1"];

    [self tapButtonWithText:JMLocalizedString(@"dialog_button_ok")
              parentElement:nil
                shouldCheck:YES];
}

- (void)performRenameActionWithEmptyName
{
    XCUIElement *alert = [self.application.alerts elementBoundByIndex:0];
    XCUIElement *textField = [alert.textFields elementBoundByIndex:0];
    // This is a hack because tapping delete button on keyboard causes tapping 'Cancel' button.
    [textField typeText:@"1"]; 
    [self deleteTextFromTextField:textField];

    [self verifyOKButtonEnabled];

    [self tapCancelButtonOnNavBarWithTitle:nil];
}

- (void)performRenameActionWithSpacesInName
{
    XCUIElement *alert = [self.application.alerts elementBoundByIndex:0];
    XCUIElement *textField = [alert.textFields elementBoundByIndex:0];
    // This is a hack because tapping delete button on keyboard causes tapping 'Cancel' button.
    [textField typeText:@"1"]; 
    [self deleteTextFromTextField:textField];
    [textField typeText:@"  "];

    [self verifyOKButtonEnabled];

    [self tapCancelButtonOnNavBarWithTitle:nil];
}

- (void)performRenameActionWithTheSameName
{
    XCUIElement *alert = [self.application.alerts elementBoundByIndex:0];
    XCUIElement *textField = [alert.textFields elementBoundByIndex:0];
    // This is a hack because tapping delete button on keyboard causes tapping 'Cancel' button.
    [textField typeText:@"1"]; 
    [self deleteTextFromTextField:textField];
    [textField typeText:kTestReportName];

    [self verifyOKButtonEnabled];

    [self tapCancelButtonOnNavBarWithTitle:nil];
}

#pragma mark - Verifying

- (void)verifyThatBackButtonHasCorrectTitle
{
    [self verifyBackButtonExistWithAlternativeTitle:nil
                                  onNavBarWithTitle:kTestReportName];
}

- (void)verifyThatSavedItemPageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:kTestReportName 
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatInfoPageOnScreen
{
    [self verifyThatSavedItemInfoPageOnScreen];
}

#pragma mark - Helpers

- (void)verifyOKButtonEnabled
{
    XCUIElement *okButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                     text:JMLocalizedString(@"dialog_button_ok")
                                                  timeout:0];
    if (okButton.isEnabled) {
        XCTFail(@"OK button should be inactive");
    }
}

@end
