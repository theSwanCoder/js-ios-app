//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (SavedItems)

- (void)givenThatSavedItemsEmpty;

- (void)deleteAllExportedResourcesIfNeed;
- (void)deleteSavedItemWithName:(NSString *)itemName
                         format:(NSString *)format;
- (void)verifyExistSavedItemWithName:(NSString *)itemName
                              format:(NSString *)format;

- (void)verifyThatReportDidSaveWithReportName:(NSString *)reportName format:(NSString *)format;

- (void)saveTestReportInHTMLFormat;
- (void)deleteTestReportInHTMLFormat;

- (void)saveTestReportInPDFFormat;
- (void)deleteTestReportInPDFFormat;

- (void)saveTestReportInXMLFormat;
- (void)deleteTestReportInXMLFormat;

- (void)openTestSavedItemInHTMLFormat;
- (void)openTestSavedItemInPDFFormat;
- (void)closeTestSavedItem;

- (void)showInfoPageSavedItemFromViewer;
- (void)closeInfoPageSavedItemFromViewer;

- (void)markSavedAsFavoriteFromInfoPage;
- (void)unmarkSavedAsFavoriteFromInfoPage;
@end