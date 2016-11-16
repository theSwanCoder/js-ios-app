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
    [self switchViewFromGridToListInSectionWithTitle:@"Saved Items"];
    [self selectFilterBy:@"All"
      inSectionWithTitle:@"Saved Items"];
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
    [self givenThatReportCellsOnScreen];
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
      inSectionWithTitle:@"Saved Items"];
    
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
      inSectionWithTitle:@"Saved Items"];
    
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
    [self givenThatReportCellsOnScreen];
    [self openSavedItemsSection];

    [self selectFilterBy:@"XLS" inSectionWithTitle:@"Saved Items"];
    
    [self deleteSavedItemWithName:kTestReportName
                           format:@"xls"];
    [self openLibrarySection];
}

- (void)openTestSavedItemInHTMLFormat
{
    [self openSavedItemsSection];
    
    [self selectFilterBy:@"HTML" inSectionWithTitle:@"Saved Items"];
    
    XCUIElement *testItem = [self savedItemWithName:kTestReportName
                                              format:@"html"];
    [testItem tap];
    [self givenLoadingPopupNotVisible];
}

- (void)openTestSavedItemInPDFFormat
{
    [self openSavedItemsSection];
    
    [self selectFilterBy:@"PDF" inSectionWithTitle:@"Saved Items"];
    
    XCUIElement *testItem = [self savedItemWithName:kTestReportName
                                             format:@"pdf"];
    [testItem tap];
    [self givenLoadingPopupNotVisible];
}

- (void)openTestSavedItemFromInfoPage
{
    [self openMenuActionsOnNavBarWithLabel:kTestReportName];
    [self selectActionWithName:@"Run"];
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

    [self deleteAllExportedResourcesIfNeed];
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
