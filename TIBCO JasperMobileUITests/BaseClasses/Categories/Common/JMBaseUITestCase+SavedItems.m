//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+SavedItems.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+InfoPage.h"
#import "JMBaseUITestCase+Buttons.h"


@implementation JMBaseUITestCase (SavedItems)

- (void)givenThatSavedItemsEmpty
{
    [self switchViewFromGridToListInSectionWithTitle:@"Saved Items"];
    [self selectFilterBy:@"All"
      inSectionWithTitle:@"Saved Items"];
    [self deleteAllSavedItemsIfNeed];
}

- (void)deleteAllSavedItemsIfNeed
{
    NSInteger countOfSavedItems = [self countCellsWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"];
    if (countOfSavedItems > 0) {
        [self deleteFirstExportedResource];
    }
}

- (void)deleteSavedItemWithName:(NSString *)itemName format:(NSString *)format
{
    XCUIElement *savedItem = [self savedItemWithName:itemName
                                              format:format];
    [self deleteSavedItem:savedItem];
}

- (void)verifyExistSavedItemWithName:(NSString *)itemName format:(NSString *)format
{
    XCUIElement *savedItem = [self savedItemWithName:itemName
                                              format:format];
    if (!savedItem) {
        XCTFail(@"Resource with name '%@' should exist", itemName);
    }
}

- (void)verifyThatReportDidSaveWithReportName:(NSString *)reportName
                                       format:(NSString *)format
{
    [self waitNotificationOnMenuButtonWithTimeout:kUITestsResourceWaitingTimeout];
    [self openSavedItemsSectionIfNeed];
    [self verifyExistSavedItemWithName:reportName
                                format:format];
}

#pragma mark - HTML
- (void)saveTestReportInHTMLFormatNeedOpen:(BOOL)needOpen
{
    [self openLibrarySectionIfNeed];
    [self saveTestReportInHTMLFormat];
    [self verifyThatReportDidSaveWithReportName:kTestReportName
                                         format:@"html"];
    if (needOpen) {
        [self openTestSavedItemInHTMLFormat];
    }
}

- (void)saveTestReportInHTMLFormat
{
    [self openTestReportPage];
    [self openSavingReportPage];
    [self saveTestReportWithName:kTestReportName
                          format:@"html"];
    [self closeTestReportPage];
}

- (void)openTestSavedItemInHTMLFormat
{
    [self openSavedItemsSectionIfNeed];

    [self selectFilterBy:@"HTML"
      inSectionWithTitle:@"Saved Items"];

    XCUIElement *testItem = [self savedItemWithName:kTestReportName
                                             format:@"html"];
    [testItem tap];
    [self givenLoadingPopupNotVisible];
}

- (void)deleteTestReportInHTMLFormat
{
    [self openSavedItemsSectionIfNeed];
    
    [self selectFilterBy:@"HTML"
      inSectionWithTitle:@"Saved Items"];

    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
    
    [self deleteSavedItemWithName:kTestReportName
                           format:@"html"];
    [self openLibrarySectionIfNeed];
}

#pragma mark - PDF

- (void)saveTestReportInPDFFormatNeedOpen:(BOOL)needOpen
{
    [self openLibrarySectionIfNeed];
    [self saveTestReportInPDFFormat];
    [self verifyThatReportDidSaveWithReportName:kTestReportName
                                         format:@"pdf"];
    if (needOpen) {
        [self openTestSavedItemInPDFFormat];
    }
}

- (void)saveTestReportInPDFFormat
{
    [self openTestReportPage];
    [self openSavingReportPage];
    [self saveTestReportWithName:kTestReportName
                          format:@"pdf"];
    [self closeTestReportPage];
}

- (void)openTestSavedItemInPDFFormat
{
    [self openSavedItemsSectionIfNeed];

    [self selectFilterBy:@"PDF"
      inSectionWithTitle:@"Saved Items"];

    XCUIElement *testItem = [self savedItemWithName:kTestReportName
                                             format:@"pdf"];
    [testItem tap];
    [self givenLoadingPopupNotVisible];
}

- (void)deleteTestReportInPDFFormat
{
    [self openSavedItemsSectionIfNeed];
    
    [self selectFilterBy:@"PDF"
      inSectionWithTitle:@"Saved Items"];

    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
    
    [self deleteSavedItemWithName:kTestReportName
                           format:@"pdf"];
    [self openLibrarySectionIfNeed];
}

#pragma mark - XLS

- (void)saveTestReportInXLSFormatNeedOpen:(BOOL)needOpen
{
    [self openLibrarySectionIfNeed];
    [self saveTestReportInXLSFormat];
    [self verifyThatReportDidSaveWithReportName:kTestReportName
                                         format:@"xls"];
    if (needOpen) {
        [self openTestSavedItemInXLSFormat];
    }
}

- (void)saveTestReportInXLSFormat
{
    [self openTestReportPage];
    [self openSavingReportPage];

    [self saveTestReportWithName:kTestReportName
                          format:@"xls"];

    [self closeTestReportPage];
}

- (void)openTestSavedItemInXLSFormat
{
    [self openSavedItemsSectionIfNeed];

    [self selectFilterBy:@"XLS"
      inSectionWithTitle:@"Saved Items"];

    XCUIElement *testItem = [self savedItemWithName:kTestReportName
                                             format:@"xls"];
    [testItem tap];
    [self givenLoadingPopupNotVisible];
}

- (void)deleteTestReportInXLSFormat
{
    [self openSavedItemsSectionIfNeed];

    [self selectFilterBy:@"XLS"
      inSectionWithTitle:@"Saved Items"];
    
    [self deleteSavedItemWithName:kTestReportName
                           format:@"xls"];
    [self openLibrarySectionIfNeed];
}

#pragma mark - Common

- (void)openTestSavedItemFromInfoPage
{
    [self openMenuActionsOnNavBarWithLabel:kTestReportName];
    [self selectActionWithName:@"Run"];
}

- (void)closeTestSavedItem
{
    [self tryBackToPreviousPage];
}

- (void)openInfoPageTestSavedItemFromViewer
{
    [self openInfoPageFromMenuActions];
}

- (void)closeInfoPageTestSavedItemFromViewer
{
    [self closeInfoPageFromMenuActions];
}

- (void)openInfoPageTestSavedItemFromSavedItemsSection
{
    [self openSavedItemsSectionIfNeed];
    
    [self selectFilterBy:@"HTML" inSectionWithTitle:@"Saved Items"];
    
    XCUIElement *testItem = [self savedItemWithName:kTestReportName
                                             format:@"html"];
    [self openInfoPageFromCell:testItem];
}

- (void)closeInfoPageTestSavedItemFromSavedItemsSection
{
    [self closeInfoPageFromCell];
}

- (void)markSavedAsFavoriteFromInfoPage
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:kTestReportName
                                                   timeout:kUITestsBaseTimeout];
    [self tapButtonWithText:@"make favorite item"
              parentElement:navBar
                shouldCheck:YES];
}

- (void)unmarkSavedAsFavoriteFromInfoPage
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:kTestReportName
                                                   timeout:kUITestsBaseTimeout];
    [self tapButtonWithText:@"favorited item"
              parentElement:navBar
                shouldCheck:YES];
}

- (void)markTestSavedItemAsFavoriteFromMenuOnInfoPage
{
    [self openMenuActionsOnNavBarWithLabel:kTestReportName];
    [self selectActionWithName:@"Mark as Favorite"];
}

- (void)unmarkTestSavedItemAsFavoriteFromMenuOnInfoPage
{
    [self openMenuActionsOnNavBarWithLabel:kTestReportName];
    [self selectActionWithName:@"Remove From Favorites"];
}

- (void)markTestSavedItemAsFavoriteFromViewerPage
{
    [self openMenuActionsOnNavBarWithLabel:kTestReportName];
    [self selectActionWithName:@"Mark as Favorite"];
}

- (void)unmarkTestSavedItemAsFavoriteFromViewerPage
{
    [self openMenuActionsOnNavBarWithLabel:kTestReportName];
    [self selectActionWithName:@"Remove From Favorites"];
}

#pragma mark - Helpers

- (void)deleteFirstExportedResource
{
    XCUIElement *firstItem = [self cellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                                  forIndex:0];
    [self deleteSavedItem:firstItem];

    [self deleteAllSavedItemsIfNeed];
}

- (void)deleteSavedItem:(XCUIElement *)savedItem
{
    [self openInfoPageFromCell:savedItem];
    [self verifyThatSavedItemInfoPageOnScreen];

    [self openMenuActions];
    [self selectActionWithName:@"Delete"];
    [self confirmDeleteAction];
}

- (void)confirmDeleteAction
{
    [self tapButtonWithText:JMLocalizedString(@"dialog_button_ok")
              parentElement:nil
                shouldCheck:YES];
}

- (XCUIElement *)savedItemWithName:(NSString *)itemName
                            format:(NSString *)format
{
    NSString *fullSavedItemName = [NSString stringWithFormat:@"%@.%@", itemName, format.lowercaseString];
    XCUIElement *savedItem = [self findCollectionViewCellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                            containsLabelWithAccessibilityId:@"JMResourceCellResourceNameLabelAccessibilityId"
                                                                   labelText:fullSavedItemName];
    return savedItem;
}

- (void)verifyThatSavedItemInfoPageOnScreen
{
    [self verifyInfoPageOnScreenForPageWithAccessibilityId:@"JMSavedItemsInfoViewControllerAccessibilityId"];
}

@end
