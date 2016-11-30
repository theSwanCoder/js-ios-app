//
//  JMDashboardPrintDialogUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMDashboardPrintDialogUITests.h"
#import "JMBaseUITestCase+Dashboard.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Printer.h"

@implementation JMDashboardPrintDialogUITests

- (void)setUp
{
    [super setUp];
    
    [self openTestDashboardPage];
    [self openPrintDashboardPage];
}

- (void)tearDown
{
    [self closePrintDashboardPage];
    [self closeTestDashboardPage];
    
    [super tearDown];
}

#pragma mark - Tests

//User should see Print Dashboard dialog
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the dashboard
//    < Tap Print button on Dashboard View screen
//    > User should see Print Dashboard dialog (screen for iPhone)
- (void)testThatUserCanSeePrintDialog
{
    [self verifyThatPrintDashboardPageOnScreen];
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
    [self verifyThatPrintDashboardPageHasCancelButton];
}

//Printer Options title
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the dashboard
//    < Tap Print button on Dashboard View screen
//    > User should see title like "Printer Options"
- (void)testThatPrinterOptionsPageHasCorrectTitle
{
    [self verifyThatPrintDashboardPageHasCorrectTitle];
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
    [self openSelectPrinterPage];
    // We need come up something with a test printer on CI to test this
    [self closeSelectPrinterPage];
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
    [self openSelectPrinterPage];
    [self verifyThatPrintersPageHasCorrentBackButton];
    [self closeSelectPrinterPage];
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
    [self openSelectPrinterPage];
    [self verifyThatPrintersPageOnScreen];
    [self closeSelectPrinterPage];
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
    [self openSelectPrinterPage];
    // We need come up something with a test printer on CI to test this
    [self closeSelectPrinterPage];
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
    [self openSelectPrinterPage];
    // We need come up something with a test printer on CI to test this
    [self closeSelectPrinterPage];
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
    [self openSelectPrinterPage];
    // We need come up something with a test printer on CI to test this
    [self closeSelectPrinterPage];
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
    [self openSelectPrinterPage];
    // We need come up something with a test printer on CI to test this
    [self closeSelectPrinterPage];
}

#pragma mark - Verifying

- (void)verifyThatPrintDashboardPageOnScreen
{
    [self verifyThatPrintDashboardPageHasCorrectTitle];
}

- (void)verifyThatPrintDashboardPageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:@"Printer Options"
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatPrintDashboardPageHasCancelButton
{
    [self waitBackButtonWithAccessibilityId:@"Cancel"
                          onNavBarWithLabel:@"Printer Options"
                                    timeout:kUITestsBaseTimeout];
}

- (void)verifyThatPrintersPageHasCorrentBackButton
{
    [self waitBackButtonWithAccessibilityId:@"Printer Options"
                          onNavBarWithLabel:@"Printer"
                                    timeout:kUITestsBaseTimeout];
}

- (void)verifyThatPrintersPageOnScreen
{
    [self waitNavigationBarWithLabel:@"Printer"
                             timeout:kUITestsBaseTimeout];
}

@end
