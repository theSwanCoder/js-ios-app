//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (SavedItems)

- (void)givenThatSavedItemsEmpty;

- (void)deleteAllSavedItemsIfNeed;
- (void)deleteSavedItemWithName:(NSString *)itemName
                         format:(NSString *)format;
- (void)verifyExistSavedItemWithName:(NSString *)itemName
                              format:(NSString *)format;

- (void)verifyThatReportDidSaveWithReportName:(NSString *)reportName format:(NSString *)format;

- (void)saveTestReportInHTMLFormatNeedOpen:(BOOL)needOpen;
- (void)openTestSavedItemInHTMLFormat;
- (void)deleteTestReportInHTMLFormat;

- (void)saveTestReportInPDFFormatNeedOpen:(BOOL)needOpen;
- (void)openTestSavedItemInPDFFormat;
- (void)deleteTestReportInPDFFormat;

- (void)saveTestReportInXLSFormatNeedOpen:(BOOL)needOpen;
- (void)openTestSavedItemInXLSFormat;
- (void)deleteTestReportInXLSFormat;

- (void)openTestSavedItemFromInfoPage;
- (void)closeTestSavedItem;

- (void)openInfoPageTestSavedItemFromViewer;
- (void)closeInfoPageTestSavedItemFromViewer;

- (void)openInfoPageTestSavedItemFromSavedItemsSection;
- (void)closeInfoPageTestSavedItemFromSavedItemsSection;

- (void)markSavedAsFavoriteFromInfoPage;
- (void)unmarkSavedAsFavoriteFromInfoPage;
- (void)markTestSavedItemAsFavoriteFromMenuOnInfoPage;
- (void)unmarkTestSavedItemAsFavoriteFromMenuOnInfoPage;
- (void)markTestSavedItemAsFavoriteFromViewerPage;
- (void)unmarkTestSavedItemAsFavoriteFromViewerPage;

- (XCUIElement *)savedItemWithName:(NSString *)itemName format:(NSString *)format;

- (void)verifyThatSavedItemInfoPageOnScreen;
@end
