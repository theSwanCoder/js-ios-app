//
// Created by Aleksandr Dakhno on 9/9/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Printer)

- (void)openSelectPrinterPage;
- (void)closeSelectPrinterPage;

- (void)verifyThatPrintPageOnScreen;
- (void)verifyThatPrintPageHasCorrectTitle;
- (void)verifyThatPrintPageHasCancelButton;
- (void)verifyThatPrintersPageOnScreen;
- (void)verifyThatPrintersPageHasCorrectBackButton;
@end