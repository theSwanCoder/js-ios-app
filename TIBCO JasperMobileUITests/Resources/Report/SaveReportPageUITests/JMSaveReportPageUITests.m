//
//  JMSaveReportPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMSaveReportPageUITests.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+SavedItems.h"
#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+Alerts.h"

@implementation JMSaveReportPageUITests

#pragma mark - Tests

//User should see Save Report screen
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save button on Report View screen
//    > User should see Save Report screen
- (void)testThatUserCanSeeSaveReportScreen
{
    [self openTestReportPage];

    [self openSavingReportPage];
    [self verifyThatSaveReportPageOnScreen];
    [self closeSaveReportPage];
    
    [self closeTestReportPage];
}

//Save Report title
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the report
//    < Tap Save button on Report View screen
//    > User should see title like "Save Report"
- (void)testThatScreenHasCorrectTitle
{
    [self openTestReportPage];

    [self openSavingReportPage];
    [self verifyThatSaveReportPageHasCorrectTitle];
    [self closeSaveReportPage];
    
    [self closeTestReportPage];
}

//Save button
//    < Launch Application
//    < Open Library screen
//    < Run the report
//    < Tap Save button on Report View screen
//    < Tap Save button on Save Report screen (save report with default name)
//    > Report is saved successfully and Report View should appear
- (void)testThatSaveButtonWorkCorrectly
{
    [self openSavedItemsSectionIfNeed];
    [self givenThatSavedItemsEmpty];

    [self saveTestReportInHTMLFormatNeedOpen:NO];
}

//Back button like name of the report
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the report
//    < Tap Save button on Report View screen
//    < Tap back button on Save Report screen
//    > Report View screen should appears
- (void)testThatBackButtonHasCorrectName
{
    [self openTestReportPage];

    [self openSavingReportPage];
    [self verifyThatSaveReportPageHasCorrectBackButtonName];
    [self closeSaveReportPage];
    
    [self closeTestReportPage];
}

//Try to save the report with empty name
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save button on Report View screen
//    < Report name should be empty
//    < Tap Save button on Save Report screen
//    > Report is not saved. User should see error message "This field is required"
- (void)testThatErrorAppearsForSavingWithEmptyName
{
    [self openTestReportPage];
    [self openSavingReportPage];
    
    [self saveTestReportWithName:@"" 
                          format:@"html"]; // We don't have translation for this string
    [self verifyErrorOfSavingReportWithEmptyName];
    
    [self closeSaveReportPage];    
    [self closeTestReportPage];
}

//Try to save the report if report name includes only spaces
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save button on Report View screen
//    < Enter some spaces in "Report Name" field
//    < Tap Save button on Save Report screen
//    > Report is not saved. User should see error message "This field is required"
- (void)testThatErrorAppearsForSavingWithSpacesInName
{
    [self openTestReportPage];
    [self openSavingReportPage];
    
    [self saveTestReportWithName:@"  " 
                          format:@"html"]; // We don't have translation for this string
    [self verifyErrorOfSavingReportWithEmptyName];
    
    [self closeSaveReportPage];    
    [self closeTestReportPage];
}

//Try to save the report with not supported symbols
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save button on Report View screen
//    < Enter some incorrect symbols ('-', '/', ':', ';', '(', ')', '$', '&', '@', ',', '?', '!', ''', '"') in "Report Name" field
//    < Tap Save button on Save Report screen
//    > Report is not saved. User should see error message "Characters '-', '/', ':', ';', '(', ')', '$', '&', '@', ',', '?', '!', ''', '"' are not allowed"
- (void)testThatErrorAppearsForSavingWithUnsupportedSymbolsInName
{
    [self openTestReportPage];
    [self openSavingReportPage];
    
    [self saveTestReportWithName:@"-" 
                          format:@"html"]; // We don't have translation for this string
    [self verifyErrorOfSavingReportWithWrongSymbolsInName];
    
    [self closeSaveReportPage];    
    [self closeTestReportPage];
}

//Try to save the report if report name already exist
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save button on Report View screen
//    < Enter correct report name and save report
//    < Tap Save button on Save Report screen
//    < Tap Save button again on Report View screen
//    < Enter the same report name and save report
//    < Tap Save button on Save Report screen
//    > Report is not saved.
//    1. User should see error message "This name already exists, choose a unique name" under report name
//    2. Should appears dialogbox with title 'Error' and message 'This name already exist, do you want to overwrite it?'
- (void)testThatErrorAppearsForSavingWithTheSameName
{
    [self openSavedItemsSectionIfNeed];
    [self givenThatSavedItemsEmpty];

    [self saveTestReportInHTMLFormatNeedOpen:NO];

    [self openLibrarySectionIfNeed];
    [self openTestReportPage];
    [self openSavingReportPage];
    
    [self saveTestReportWithName:kTestReportName
                          format:@"html"]; // We don't have translation for this string
    [self verifyThatAlertItemExistsVisible];
    [self cancelSavingTestReport];
    
    [self closeSaveReportPage];    
    [self closeTestReportPage]; 
}

//Try to save the report if report name already exist - 'Cancel' button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save button on Report View screen
//    < Enter correct report name and save report
//    < Tap Save button on Save Report screen
//    < Tap Save button again on Report View screen
//    < Enter the same report name and save report
//    < Tap Save button on Save Report screen
//    < Tap on 'Cancel' button
//    > Should appears 'Error' dialogbox
//    > Existing report should not be overwritten
- (void)testThatErrorAppearsForSavingWithTheSameNameAndChooseCancelAction
{
    [self openSavedItemsSectionIfNeed];
    [self givenThatSavedItemsEmpty];

    [self saveTestReportInHTMLFormatNeedOpen:NO];

    [self openLibrarySectionIfNeed];
    [self openTestReportPage];
    [self openSavingReportPage];
    
    [self saveTestReportWithName:kTestReportName
                          format:@"html"]; // We don't have translation for this string
    [self cancelSavingTestReport];
    
    [self closeSaveReportPage];    
    [self closeTestReportPage]; 
}

//Try to save the report if report name already exist - 'OK' button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save button on Report View screen
//    < Enter correct report name and save report
//    < Tap Save button on Save Report screen
//    < Tap Save button again on Report View screen
//    < Enter the same report name and save report
//    < Tap Save button on Save Report screen
//    < Tap on 'OK' button
//    > Should appears 'Error' dialogbox
//    > Existing report should be overwritten
- (void)testThatReportCanBeOverwritten
{
    [self openSavedItemsSectionIfNeed];
    [self givenThatSavedItemsEmpty];

    [self saveTestReportInHTMLFormatNeedOpen:NO];

    [self openLibrarySectionIfNeed];
    [self openTestReportPage];
    [self openSavingReportPage];
    
    [self saveTestReportWithName:kTestReportName
                          format:@"html"]; // We don't have translation for this string
    [self confirmOverridingTestReport];
    
    [self closeTestReportPage]; 
    
    [self verifyThatReportDidSaveWithReportName:kTestReportName
                                         format:@"html"]; // We don't have translation for this string
    [self openLibrarySectionIfNeed];
}

//Save the report as html-file
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save button on Report View screen
//    < Enter correct report name
//    < Choose Output Format as html
//    < Tap Save button on Save Report screen
//    > Report is saved as html-file
- (void)testThatReportCanBeSavedInHTMLformat
{
    [self openSavedItemsSectionIfNeed];
    [self givenThatSavedItemsEmpty];

    [self saveTestReportInHTMLFormatNeedOpen:YES];
    [self closeTestSavedItem];
}

//Save the report as pdf-file
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save button on Report View screen
//    < Enter correct report name
//    < Choose Output Format as pdf
//    < Tap Save button on Save Report screen
//    > Report is saved as pdf-file
- (void)testThatReportCanBeSavedInPDFformat
{
    [self openSavedItemsSectionIfNeed];
    [self givenThatSavedItemsEmpty];

    [self saveTestReportInPDFFormatNeedOpen:YES];
    [self closeTestSavedItem];
}

//Save the report as xls-file
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save button on Report View screen
//    < Enter correct report name
//    < Choose Output Format as xls
//    < Tap Save button on Save Report screen
//    > Report is saved as xls-file
- (void)testThatReportCanBeSavedInXLSformat
{
    [self openSavedItemsSectionIfNeed];
    [self givenThatSavedItemsEmpty];

    [self saveTestReportInXLSFormatNeedOpen:YES];
    [self closeTestSavedItem];
}

//Save the report with same name but in different output formats
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save button on Report View screen
//    < Enter correct report name
//    < Choose Output Format as html
//    < Tap Save button on Save Report screen
//    < Tap Save button on Report View screen
//    < Enter the same report name
//    < Choose Output Format as pdf
//    < Tap Save button on Save Report screen
//    < Tap Save button on Report View screen
//    < Enter the same report name
//    < Choose Output Format as xls
//    < Tap Save button on Save Report screen
//    > All report are saved with same name but in different output formats
- (void)testThatReportCanBeSavedWithTheSameNameButDifferentFormat
{
    [self openSavedItemsSectionIfNeed];
    [self givenThatSavedItemsEmpty];

    [self saveTestReportInHTMLFormatNeedOpen:NO];
    [self saveTestReportInXLSFormatNeedOpen:NO];
}

//Cancel saving
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save button on Report View screen
//    < Enter correct report name
//    < Tap Save button on Save Report screen
//    < Tap Cancel button on loader when report is saving
//    > Report isn't saved
- (void)testThatSavingCanBeCanceled
{
//    XCTFail(@"Not implemented tests");
}

#pragma mark - Helpers

- (void)cancelSavingTestReport
{
    XCUIElement *alert = [self waitAlertWithTitle:JMLocalizedString(@"dialod_title_error")
                                          timeout:kUITestsBaseTimeout];
    [self tapButtonWithText:JMLocalizedString(@"dialog_button_cancel")
              parentElement:alert
                shouldCheck:YES];
}

- (void)confirmOverridingTestReport
{
    XCUIElement *alert = [self waitAlertWithTitle:JMLocalizedString(@"dialod_title_error")
                                          timeout:kUITestsBaseTimeout];
    [self tapButtonWithText:JMLocalizedString(@"dialog_button_ok")
              parentElement:alert
                shouldCheck:YES];
}

#pragma mark - Verifying

- (void)verifyThatSaveReportPageOnScreen
{
    // TODO: replace with accessibility id of view
    [self waitNavigationBarWithLabel:@"Save Report" // We don't have translation for this string
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatSaveReportPageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:@"Save Report" // We don't have translation for this string
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatSaveReportPageHasCorrectBackButtonName
{
    // TODO: need make general case for all devices, 'Back' on iPhones
    [self verifyBackButtonExistWithAlternativeTitle:nil
                                  onNavBarWithTitle:@"Save Report"]; // We don't have translation for this string
}

- (void)verifyErrorOfSavingReportWithEmptyName
{
    XCUIElement *tableView = [self.application.tables elementBoundByIndex:0];
    XCUIElement *nameCell = [tableView.cells elementBoundByIndex:0];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_viewer_save_name_errmsg_empty")
                    parentElement:nameCell
                          timeout:kUITestsBaseTimeout];
}

- (void)verifyErrorOfSavingReportWithWrongSymbolsInName
{
    XCUIElement *tableView = [self.application.tables elementBoundByIndex:0];
    XCUIElement *nameCell = [tableView.cells elementBoundByIndex:0];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"are not allowed." // We don't have translation for this string
                    parentElement:nameCell
                          timeout:kUITestsBaseTimeout];
}

- (void)verifyThatAlertItemExistsVisible
{    
    [self waitAlertWithTitle:JMLocalizedString(@"dialod_title_error")
                     timeout:kUITestsBaseTimeout];
}

@end
