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
    XCUIElement *closeButton = [self waitBackButtonWithAccessibilityId:@"Printer Options" timeout:kUITestsBaseTimeout];
    [closeButton tap];
}

@end
