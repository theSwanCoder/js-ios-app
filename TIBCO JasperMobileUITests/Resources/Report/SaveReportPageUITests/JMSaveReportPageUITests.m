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
    
    [self openSaveReportPage];
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
    
    [self openSaveReportPage];
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
    [self givenThatSavedItemsEmpty];
    
    [self saveTestReportInHTMLFormat];
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
    
    [self openSaveReportPage];
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
    [self openSaveReportPage];
    
    [self saveTestReportWithName:@"" 
                          format:@"html"];
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
    [self openSaveReportPage];
    
    [self saveTestReportWithName:@"  " 
                          format:@"html"];
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
    [self openSaveReportPage];
    
    [self saveTestReportWithName:@"-" 
                          format:@"html"];
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
    [self givenThatSavedItemsEmpty];
    
    [self saveTestReportInHTMLFormat];
    
    [self openTestReportPage];    
    [self openSaveReportPage];
    
    [self saveTestReportWithName:kTestReportName
                          format:@"html"];
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
    [self givenThatSavedItemsEmpty];
    
    [self saveTestReportInHTMLFormat];
    
    [self openTestReportPage];    
    [self openSaveReportPage];
    
    [self saveTestReportWithName:kTestReportName
                          format:@"html"];
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
    [self givenThatSavedItemsEmpty];
    
    [self saveTestReportInHTMLFormat];
    
    [self openTestReportPage];    
    [self openSaveReportPage];
    
    [self saveTestReportWithName:kTestReportName
                          format:@"html"];
    [self confirmOverridingTestReport];
    
    [self closeTestReportPage]; 
    
    [self verifyThatReportDidSaveWithReportName:kTestReportName
                                         format:@"html"];
    [self openLibrarySection];
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
    [self givenThatSavedItemsEmpty];
    
    [self saveTestReportInHTMLFormat];
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
    [self givenThatSavedItemsEmpty];
    
    [self saveTestReportInPDFFormat];
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
    [self givenThatSavedItemsEmpty];
    
    [self saveTestReportInXLSFormat];
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
    [self givenThatSavedItemsEmpty];
    
    [self saveTestReportInHTMLFormat];    
    [self saveTestReportInXLSFormat];
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
    XCUIElement *alert = [self waitAlertWithTitle:@"Error"
                                          timeout:kUITestsBaseTimeout];
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"Cancel" 
                                                      parentElement:alert
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

- (void)confirmOverridingTestReport
{
    XCUIElement *alert = [self waitAlertWithTitle:@"Error"
                                          timeout:kUITestsBaseTimeout];
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"OK" 
                                                      parentElement:alert
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

#pragma mark - Verifying

- (void)verifyThatSaveReportPageOnScreen
{
    // TODO: replace with accessibility id of view
    [self waitNavigationBarWithLabel:@"Save Report"
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatSaveReportPageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:@"Save Report"
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatSaveReportPageHasCorrectBackButtonName
{
    // TODO: need make general case for all devices, 'Back' on iPhones
    [self waitBackButtonWithAccessibilityId:@"Back"
                          onNavBarWithLabel:@"Save Report"
                                    timeout:kUITestsBaseTimeout];
}

- (void)verifyErrorOfSavingReportWithEmptyName
{
    XCUIElement *tableView = [self.application.tables elementBoundByIndex:0];
    XCUIElement *nameCell = [tableView.cells elementBoundByIndex:0];
    [self waitStaticTextWithText:@"This field is required." 
                   parentElement:nameCell
                         timeout:kUITestsBaseTimeout];
}

- (void)verifyErrorOfSavingReportWithWrongSymbolsInName
{
    XCUIElement *tableView = [self.application.tables elementBoundByIndex:0];
    XCUIElement *nameCell = [tableView.cells elementBoundByIndex:0];
    [self waitStaticTextWithText:@"are not allowed." 
                   parentElement:nameCell
                         timeout:kUITestsBaseTimeout];
}

- (void)verifyThatAlertItemExistsVisible
{    
    [self waitAlertWithTitle:@"Error"
                     timeout:kUITestsBaseTimeout];
}

@end
