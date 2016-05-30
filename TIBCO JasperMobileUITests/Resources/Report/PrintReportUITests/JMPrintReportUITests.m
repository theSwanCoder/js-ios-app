//
//  JMPrintReportUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMPrintReportUITests.h"

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
//    XCTFail(@"Not implemented tests");
}

//Printer Options title
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the report
//    < Tap Print button on Report View screen
//    > User should see title like "Printer Options"
- (void)testThatPrintDialogHasOptionsWithTitle
{
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
}

@end
