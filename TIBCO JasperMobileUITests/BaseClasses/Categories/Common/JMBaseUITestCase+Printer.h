/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

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
