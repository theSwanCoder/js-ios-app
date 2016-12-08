//
// Created by Aleksandr Dakhno on 9/9/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Printer.h"
#import "JMBaseUITestCase+Helpers.h"


@implementation JMBaseUITestCase (Printer)

- (void)openSelectPrinterPage
{
    XCUIElement *selectPrinter = [self waitStaticTextWithAccessibilityId:@"Select Printer"
                                                                 timeout:kUITestsBaseTimeout];
    [selectPrinter tap];
}

- (void)closeSelectPrinterPage
{
    XCUIElement *backButton = [self waitBackButtonWithAccessibilityId:@"Printer Options"
                                                    onNavBarWithLabel:@"Printer"
                                                              timeout:kUITestsBaseTimeout];
    [backButton tap];
}

#pragma mark - Verifying

- (void)verifyThatPrintPageOnScreen
{
    [self waitNavigationBarWithLabel:@"Printer Options"
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatPrintPageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:@"Printer Options"
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatPrintPageHasCancelButton
{
    [self waitBackButtonWithAccessibilityId:@"Cancel"
                          onNavBarWithLabel:@"Printer Options"
                                    timeout:kUITestsBaseTimeout];
}

- (void)verifyThatPrintersPageOnScreen
{
    [self waitNavigationBarWithLabel:@"Printer"
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatPrintersPageHasCorrectBackButton
{
    [self waitBackButtonWithAccessibilityId:@"Printer Options"
                          onNavBarWithLabel:@"Printer"
                                    timeout:kUITestsBaseTimeout];
}

@end
