//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+SavedItems.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Resource.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+Section.h"


@implementation JMBaseUITestCase (SavedItems)

- (void)givenThatSavedItemsEmpty
{
    [self openSavedItemsSection];
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
    [self givenThatLibraryPageOnScreen];
    [self openSavedItemsSection];
    [self selectFilterBy:@"HTML" inSectionWithTitle:@"Saved Items"];
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
    [self givenThatLibraryPageOnScreen];
    [self openSavedItemsSection];
    [self selectFilterBy:@"PDF" inSectionWithTitle:@"Saved Items"];
    [self deleteSavedItemWithName:kTestReportName
                           format:@"pdf"];
    [self openLibrarySection];
}

- (void)saveTestReportInXMLFormat
{
    [self openTestReportPage];
    [self openSaveReportPage];

    [self saveTestReportWithName:kTestReportName
                          format:@"xml"];

    [self closeTestReportPage];

    [self verifyThatReportDidSaveWithReportName:kTestReportName
                                         format:@"xml"];
    [self openLibrarySection];
}

- (void)deleteTestReportInXMLFormat
{
    [self givenThatLibraryPageOnScreen];
    [self openSavedItemsSection];

    [self deleteSavedItemWithName:kTestReportName
                           format:@"xml"];
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
    [self openMenuActionsOnNavBarWithLabel:kTestReportName];
    [self selectActionWithName:@"Run"];
}

- (void)closeTestSavedItem
{
    [self tryBackToPreviousPage];
}

- (void)showInfoPageTestSavedItemFromViewer
{
    [self openMenuActions];
    [self selectActionWithName:@"Info"];
}

- (void)closeInfoPageTestSavedItemFromViewer
{
    [self closeInfoPageWithCancelButton];
}

- (void)showInfoPageTestSavedItemFromSavedItemsSection
{
    [self openSavedItemsSection];
    
    XCUIElement *testItem = [self savedItemWithName:kTestReportName
                                             format:@"html"];

    [self openInfoPageForResource:testItem];
}

- (void)closeInfoPageTestSavedItemFromSavedItemsSection
{
    [self closeInfoPageWithBackButton];
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
    [self openInfoPageForResource:savedItem];
    [self verifyInfoPageOnScreenForPageWithAccessibilityId:@"JMSavedItemsInfoViewControllerAccessibilityId"];

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

@end
