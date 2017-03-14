/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMBaseUITestCase+Printer.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Buttons.h"
#import "XCUIElement+Tappable.h"


@implementation JMBaseUITestCase (Printer)

- (void)openSelectPrinterPage
{
    // We don't have translate for this string
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
    // We don't have translate for this string
    XCUIElement *navBar = [self waitNavigationBarWithLabel:@"Printer"
                                                   timeout:kUITestsBaseTimeout];
    // We don't have translate for this string
    [self tapButtonWithText:@"Printer Options"
              parentElement:navBar
                shouldCheck:YES];
}

#pragma mark - Verifying

- (void)verifyThatPrintPageOnScreen
{
    // We don't have translate for this string
    [self waitNavigationBarWithLabel:@"Printer Options"
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatPrintPageHasCorrectTitle
{
    // We don't have translate for this string
    [self waitNavigationBarWithLabel:@"Printer Options"
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatPrintPageHasCancelButton
{
    // We don't have translate for this string
    [self verifyCancelButtonExistOnNavBarWithTitle:@"Printer Options"];
}

- (void)verifyThatPrintersPageOnScreen
{
    // We don't have translate for this string
    [self waitNavigationBarWithLabel:@"Printer"
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatPrintersPageHasCorrectBackButton
{
    // We don't have translate for this string
    XCUIElement *navBar = [self waitNavigationBarWithLabel:@"Printer"
                                                   timeout:kUITestsBaseTimeout];
    // We don't have translate for this string
    [self verifyButtonExistWithText:@"Printer Options"
                      parentElement:navBar];
}

@end
