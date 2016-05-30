//
//  JMDashboardPrintDialogUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMDashboardPrintDialogUITests.h"

@implementation JMDashboardPrintDialogUITests

#pragma mark - Tests

//User should see Print Dashboard dialog
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Tap Print button on Dashboard View screen
//    > User should see Print Dashboard dialog (screen for iPhone)
- (void)testThatUserCanSeePrintDialog
{
//    XCTFail(@"Not implemented tests");
}

//Cancel button on Print Options dialog
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the dashboard
//    < Tap Print button on Dashboard View screen
//    < Tap Cancel button on Print Options dialog
//    > Dashboard View screen should appears
- (void)testThatCancelButtonWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Printer Options title
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the dashboard
//    < Tap Print button on Dashboard View screen
//    > User should see title like "Printer Options"
- (void)testThatPrinterOptionsPageHasCorrectTitle
{
//    XCTFail(@"Not implemented tests");
}

//Printer button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the dashboard
//    < Tap Print button on Dashboard View screen
//    < Tap Printer button on Printer Otions dialog
//    < Select one of available printers
//    > User can choose one of available printers
- (void)testThatPrinterButtonWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Printer Options back button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the dashboard
//    < Tap Print button on Dashboard View screen
//    < Tap Printer button on Printer Otions dialog
//    < Tap Printer Options back button
//    > Printer Otions dialog should appears
- (void)testThatPrinterOptionsBackButtonWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Printer title
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the dashboard
//    < Tap Print button on Dashboard View screen
//    < Tap Printer button on Printer Otions dialog
//    > User should see title like "Printer"
- (void)testThatPageHasCorrectTitle
{
//    XCTFail(@"Not implemented tests");
}

//Print button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the dashboard
//    < Tap Print button on Dashboard View screen
//    < Tap Print button on Printer Options dialog
//    > Dashboard should be printed
- (void)testThatPrintButtonWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Number of copies
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the dashboard
//    < Tap Print button on Dashboard View screen
//    < Tap Plus button and tap Print button on Printer Options dialog
//    < Tap Minus button and tap Print button on Printer Options dialog
//    > Dashboard should be printed with appropriate number of copies
- (void)testThatNumberOfCopiesCanBeSelected
{
//    XCTFail(@"Not implemented tests");
}

//Double-sided option (disabled)
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the dashboard
//    < Tap Print button on Dashboard View screen
//    < Disable Double-sided option
//    < Tap Print button on Printer Options dialog
//    > Dashboard should be printed only on one side of paper
- (void)testThatDoubleSidedOptionEnabledIfPrinterHasSuchOption
{
//    XCTFail(@"Not implemented tests");
}

//Double-sided option (enabled)
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the dashboard
//    < Tap Print button on Dashboard View screen
//    < Enable Double-sided option
//    < Tap Print button on Printer Options dialog
//    > Dashboard should be printed only on one side of paper
- (void)testThatDoubleSidedOptionDisabledIfPrinterHasNotSuchOption
{
//    XCTFail(@"Not implemented tests");
}

@end
