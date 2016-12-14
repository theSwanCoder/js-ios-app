//
// Created by Aleksandr Dakhno on 9/9/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Printer.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Buttons.h"
#import "XCUIElement+Tappable.h"


@implementation JMBaseUITestCase (Printer)

- (void)openSelectPrinterPage
{
    XCUIElement *selectPrinter = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                          text:@"Select Printer"
                                                       timeout:kUITestsBaseTimeout];
    if (selectPrinter.exists) {
        [selectPrinter tapByWaitingHittable];
    } else {
        XCTFail(@"Select printer button doesn't exist");
    }
}

- (void)closeSelectPrinterPage
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:@"Printer"
                                                   timeout:kUITestsBaseTimeout];
    [self tapButtonWithText:@"Printer Options"
              parentElement:navBar
                shouldCheck:YES];
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
    [self verifyCancelButtonExistOnNavBarWithTitle:@"Printer Options"];
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
    [self verifyButtonExistWithText:@"Printer Options"
                      parentElement:navBar];
}

@end
