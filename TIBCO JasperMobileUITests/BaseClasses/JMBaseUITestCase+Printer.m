//
// Created by Aleksandr Dakhno on 9/9/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Printer.h"
#import "JMBaseUITestCase+Helpers.h"


@implementation JMBaseUITestCase (Printer)

- (void)openSelectPrinterPage
{
    XCUIElement *selectPrinter = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                          text:@"Select Printer"
                                                       timeout:kUITestsBaseTimeout];
    if (selectPrinter.exists) {
        [selectPrinter tap];
    } else {
        XCTFail(@"Select printer button doesn't exist");
    }
}

- (void)closeSelectPrinterPage
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:@"Printer"
                                                   timeout:kUITestsBaseTimeout];
    XCUIElement *backButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                       text:@"Printer Options"
                                              parentElement:navBar
                                                    timeout:0];
    if (backButton.exists) {
        [backButton tap];
    } else {
        XCTFail(@"Back button wasn't found");
    }
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
    XCUIElement *navBar = [self waitNavigationBarWithLabel:@"Printer Options"
                                                   timeout:kUITestsBaseTimeout];
    XCUIElement *cancelButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                       text:@"Cancel"
                                              parentElement:navBar
                                                    timeout:0];
    if (cancelButton.exists) {
        [cancelButton tap];
    } else {
        XCTFail(@"Cancel button wasn't found");
    }

}

- (void)verifyThatPrintersPageOnScreen
{
    [self waitNavigationBarWithLabel:@"Printer"
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatPrintersPageHasCorrectBackButton
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:@"Printer"
                                                   timeout:kUITestsBaseTimeout];
    XCUIElement *backButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                       text:@"Printer Options"
                                              parentElement:navBar
                                                    timeout:0];
    if (!backButton.exists) {
        XCTFail(@"Back button wasn't found");
    }
}

@end
