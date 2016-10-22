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


@implementation JMBaseUITestCase (SavedItems)

- (void)givenThatSavedItemsEmpty
{
    [self openSavedItemsSection];
    [self switchViewFromGridToListInSectionWithAccessibilityId:JMSavedItemsPageAccessibilityId];
    [self deleteAllExportedResourcesIfNeed];
    [self openLibrarySection];
}

- (void)deleteAllExportedResourcesIfNeed
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
    [self waitNotificationOnMenuButtonWithTimeout:kUITestsBaseTimeout];
    [self openSavedItemsSection];
    [self verifyExistSavedItemWithName:reportName
                                format:format];
}

- (void)saveTestReportInHTMLFormat
{
    [self givenThatLibraryPageOnScreen];
//    [self givenThatReportCellsOnScreen];
    [self openTestReportPage];
    [self openSaveReportPage];

    [self saveTestReportWithName:kTestReportName
                          format:@"html"];

    [self closeTestReportPage];

    [self verifyThatReportDidSaveWithReportName:kTestReportName
                                         format:@"html"];
    [self openLibrarySection];
}

- (void)deleteTestReportInHTMLFormat
{
    [self openSavedItemsSection];
    
    [self selectFilterBy:@"HTML"
      inSectionWithAccessibilityId:JMSavedItemsPageAccessibilityId];
    
    [self verifyThatCollectionViewContainsCells];
    
    [self deleteSavedItemWithName:kTestReportName
                           format:@"html"];
    [self openLibrarySection];
}

- (void)saveTestReportInPDFFormat
{
    [self openTestReportPage];
    [self openSaveReportPage];

    [self saveTestReportWithName:kTestReportName
                          format:@"pdf"];

    [self closeTestReportPage];

    [self verifyThatReportDidSaveWithReportName:kTestReportName
                                         format:@"pdf"];
    [self openLibrarySection];
}

- (void)deleteTestReportInPDFFormat
{
    [self openSavedItemsSection];
    
    [self selectFilterBy:@"PDF"
      inSectionWithAccessibilityId:JMSavedItemsPageAccessibilityId];
    
    [self verifyThatCollectionViewContainsCells];
    
    [self deleteSavedItemWithName:kTestReportName
                           format:@"pdf"];
    [self openLibrarySection];
}

- (void)saveTestReportInXLSFormat
{
    [self openTestReportPage];
    [self openSaveReportPage];

    [self saveTestReportWithName:kTestReportName
                          format:@"xls"];

    [self closeTestReportPage];

    [self verifyThatReportDidSaveWithReportName:kTestReportName
                                         format:@"xls"];
    [self openLibrarySection];
}

- (void)deleteTestReportInXLSFormat
{
    [self givenThatLibraryPageOnScreen];
//    [self givenThatReportCellsOnScreen];
    [self openSavedItemsSection];

    [self deleteSavedItemWithName:kTestReportName
                           format:@"xls"];
    [self openLibrarySection];
}

- (void)openTestSavedItemInHTMLFormat
{
    [self openSavedItemsSection];
    
    XCUIElement *testItem = [self savedItemWithName:kTestReportName
                                              format:@"html"];
    [testItem tap];
    [self givenLoadingPopupNotVisible];
}

- (void)openTestSavedItemInPDFFormat
{
    [self openSavedItemsSection];

    XCUIElement *testItem = [self savedItemWithName:kTestReportName
                                             format:@"pdf"];
    [testItem tap];
    [self givenLoadingPopupNotVisible];
}

- (void)openTestSavedItemFromInfoPage
{
    [self openMenuActionsWithControllerAccessibilityId:JMSavedItemsInfoPageAccessibilityId];
    [self selectActionWithAccessibility:JMMenuActionsViewRunActionAccessibilityId];
}

- (void)closeTestSavedItem
{
    [self tryBackToPreviousPage];
}

- (void)showInfoPageTestSavedItemFromViewer
{
    [self openInfoPageFromMenuActions];
}

- (void)closeInfoPageTestSavedItemFromViewer
{
    [self closeInfoPageFromMenuActions];
}

- (void)showInfoPageTestSavedItemFromSavedItemsSection
{
    [self openSavedItemsSection];
    
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
    XCUIElement *favoriteButton = [self waitButtonWithAccessibilityId:@"make favorite item"
                                                        parentElement:navBar
                                                              timeout:kUITestsBaseTimeout];
    [favoriteButton tap];
}

- (void)unmarkSavedAsFavoriteFromInfoPage
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:kTestReportName
                                                   timeout:kUITestsBaseTimeout];
    XCUIElement *favoriteButton = [self waitButtonWithAccessibilityId:@"favorited item"
                                                        parentElement:navBar
                                                              timeout:kUITestsBaseTimeout];
    [favoriteButton tap];
}

- (void)markTestSavedItemAsFavoriteFromMenuOnInfoPage
{
    [self openMenuActionsWithControllerAccessibilityId:JMSavedItemsInfoPageAccessibilityId];
    [self selectActionWithAccessibility:JMMenuActionsViewMarkAsFavoriteActionAccessibilityId];
}

- (void)unmarkTestSavedItemAsFavoriteFromMenuOnInfoPage
{
    [self openMenuActionsWithControllerAccessibilityId:JMSavedItemsInfoPageAccessibilityId];
    [self selectActionWithAccessibility:JMMenuActionsViewMarkAsUnFavoriteActionAccessibilityId];
}

- (void)markTestSavedItemAsFavoriteFromViewerPage
{
    [self openMenuActionsWithControllerAccessibilityId:JMSavedItemsInfoPageAccessibilityId];
    [self selectActionWithAccessibility:JMMenuActionsViewMarkAsFavoriteActionAccessibilityId];
}

- (void)unmarkTestSavedItemAsFavoriteFromViewerPage
{
    [self openMenuActionsWithControllerAccessibilityId:JMSavedItemsInfoPageAccessibilityId];
    [self selectActionWithAccessibility:JMMenuActionsViewMarkAsUnFavoriteActionAccessibilityId];
}

#pragma mark - Helpers

- (void)deleteFirstExportedResource
{
    XCUIElement *firstItem = [self cellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                                  forIndex:0];
    [self deleteSavedItem:firstItem];

    [self deleteAllExportedResourcesIfNeed];
}

- (void)deleteSavedItem:(XCUIElement *)savedItem
{
    [self openInfoPageFromCell:savedItem];
    [self verifyThatSavedItemInfoPageOnScreen];

    [self openMenuActionsWithControllerAccessibilityId:JMSavedItemsPageAccessibilityId];
    [self selectActionWithAccessibility:JMMenuActionsViewDeleteActionAccessibilityId];
    [self confirmDeleteAction];
}

- (void)confirmDeleteAction
{
    XCUIElement *okButton = [self waitButtonWithAccessibilityId:@"OK"
                                                        timeout:kUITestsBaseTimeout];
    [okButton tap];
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
