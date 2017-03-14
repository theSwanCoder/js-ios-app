/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMPrintReportUITests.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+Dashboard.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Printer.h"
#import "JMBaseUITestCase+Buttons.h"

@implementation JMPrintReportUITests

#pragma mark - Tests

//User should see Print Report dialog
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Print button on Report View screen
//    > User should see Print Report dialog (screen for iPhone)
- (void)testThatUserCanSeePrintDialog
{
    [self openTestReportPage];
    [self openPrintReportPage];

    [self verityThatPrintPageOnScreen];

    [self closePrintReportPage];
    [self closeTestReportPage];
}

//Printer Options title
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the report
//    < Tap Print button on Report View screen
//    > User should see title like "Printer Options"
- (void)testThatPrintDialogHasOptionsWithTitle
{
    [self openTestReportPage];
    [self openPrintReportPage];
    
    [self verityThatPrintPageHasCorrectTitle];
    
    [self closePrintReportPage];
    [self closeTestReportPage];
}

//Printer button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the report
//    < Tap Print button on Report View screen
//    < Tap Printer button on Printer Otions dialog
//    < Select one of available printers
//    > User can choose one of available printers
- (void)testThatPrintDialogHasPrinterButton
{
    [self openTestReportPage];
    [self openPrintReportPage];
    
    // We need come up something with a test printer on CI to test this
    
    [self closePrintReportPage];
    [self closeTestReportPage];
}

//Printer title
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the report
//    < Tap Print button on Report View screen
//    < Tap Printer button on Printer Otions dialog
//    > User should see title like "Printer"
- (void)testThatPrintDialogHasTitle
{
    [self openTestReportPage];
    [self openPrintReportPage];
    
    [self openSelectPrinterPage];
    [self verifyThatPrinterPageHasCorrectTitle];
    [self closeSelectPrinterPage];
    
    [self closePrintReportPage];
    [self closeTestReportPage];
}

//Printer Options back button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the report
//    < Tap Print button on Report View screen
//    < Tap Printer button on Printer Otions dialog
//    < Tap Printer Options back button
//    > Printer Otions dialog should appears
- (void)testThatBackButtonForPrinterOptionsWorkCorrectly
{
    [self openTestReportPage];
    [self openPrintReportPage];
    
    [self openSelectPrinterPage];
    [self verifyThatPrintersPageHasCorrentBackButton];
    [self closeSelectPrinterPage];
    
    [self closePrintReportPage];
    [self closeTestReportPage];
}

//Print button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the report
//    < Tap Print button on Report View screen
//    < Tap Print button on Printer Options dialog
//    > Report should be printed
- (void)testThatPrintDialogHasPrintButton
{
    [self openTestReportPage];
    [self openPrintReportPage];

    // We need come up something with a test printer on CI to test this

    [self closePrintReportPage];
    [self closeTestReportPage];
}

//Cancel button on Print Options dialog
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the report
//    < Tap Print button on Report View screen
//    < Tap Cancel button on Print Options dialog
//    > Report View screen should appears
- (void)testThatCancelButtonForPrinterOptionWorkCorrectly
{
    [self openTestReportPage];
    [self openPrintReportPage];

    // We need come up something with a test printer on CI to test this

    [self closePrintReportPage];
    [self closeTestReportPage];
}

//Number of copies
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the report
//    < Tap Print button on Report View screen
//    < Tap Plus button and tap Print button on Printer Options dialog
//    < Tap Minus button and tap Print button on Printer Options dialog
//    > Report should be printed with appropriate number of copies
- (void)testThatNumberOfCopiesCanBeChosen
{
    [self openTestReportPage];
    [self openPrintReportPage];

    // We need come up something with a test printer on CI to test this

    [self closePrintReportPage];
    [self closeTestReportPage];
}

//Double-sided option (enabled)
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the multipage report
//    < Tap Print button on Report View screen
//    < Enable Double-sided option
//    < Tap Print button on Printer Options dialog
//    > Report should be printed on both sides of paper
- (void)testThatDoubleSidedOptionVisibleWhenEnabledOnPrinter
{
    [self openTestReportPage];
    [self openPrintReportPage];

    // We need come up something with a test printer on CI to test this

    [self closePrintReportPage];
    [self closeTestReportPage];
}

//Double-sided option (disabled)
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the multipage report
//    < Tap Print button on Report View screen
//    < Disable Double-sided option
//    < Tap Print button on Printer Options dialog
//    > Report should be printed only on one side of paper
- (void)testThatDoubleSidedOptionNotVisibleWhenDisabledOnPrinter
{
    [self openTestReportPage];
    [self openPrintReportPage];

    // We need come up something with a test printer on CI to test this

    [self closePrintReportPage];
    [self closeTestReportPage];
}

#pragma mark - Verifying

- (void)verityThatPrintPageOnScreen
{
    [self verityThatPrintPageHasCorrectTitle];
}

- (void)verityThatPrintPageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:@"Printer Options" // We don't have translation for this string
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatPrinterPageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:@"Printer" // We don't have translation for this string
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatPrintersPageHasCorrentBackButton
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:@"Printer"]; // We don't have translation for this string
    [self verifyButtonExistWithText:@"Printer Options" // We don't have translation for this string
                      parentElement:navBar];
}
@end
