/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMBaseUITestCase+Favorites.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+Dashboard.h"
#import "JMBaseUITestCase+InfoPage.h"
#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+Cells.h"


@implementation JMBaseUITestCase (Favorites)

- (void)givenThatFavoritesSectionIsEmpty
{
    [self openFavoritesSectionIfNeed];
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_all")
      inSectionWithTitle:JMLocalizedString(@"menuitem_favorites_label")];
    [self switchViewFromGridToListInSectionWithTitle:JMLocalizedString(@"menuitem_favorites_label")];
    [self unmarkAllFavoritesResourcesIfNeed];
    [self openLibrarySectionIfNeed];
}

- (void)unmarkAllFavoritesResourcesIfNeed
{
    NSInteger countOfSavedItems = [self countCellsWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"];
    if (countOfSavedItems > 0) {
        [self unmarkFirstResource];
    }
}

#pragma mark - Reports

- (void)markTestReportAsFavoriteFromSectionWithName:(NSString *)sectionName
{
    [self openInfoPageForTestReportFromSectionWithName:sectionName];
    // TODO: do we need verify that item isn't favorite
    [self markAsFavoriteFromMenuActions];
    [self closeInfoPageFromCell];
}

- (void)unmarkTestReportFromFavoriteFromSectionWithName:(NSString *)sectionName
{
    [self openInfoPageForTestReportFromSectionWithName:sectionName];
    // TODO: do we need verify that item is favorite
    [self unmarkFromFavoritesFromMenuActions];
    [self closeInfoPageFromCell];
}

#pragma mark - Dashboards

- (void)markTestDashboardAsFavoriteFromSectionWithName:(NSString *)sectionName
{
    [self openInfoPageForTestDashboardFromSectionWithName:sectionName];
    // TODO: do we need verify that item isn't favorite
    [self markAsFavoriteFromMenuActions];
    [self closeInfoPageFromCell];
}

- (void)unmarkTestDashboardFromFavoriteFromSectionWithName:(NSString *)sectionName
{
    [self openInfoPageForTestDashboardFromSectionWithName:sectionName];
    // TODO: do we need verify that item is favorite
    [self unmarkFromFavoritesFromMenuActions];
    [self closeInfoPageFromCell];
}

#pragma mark - General methods

- (void)markAsFavoriteFromMenuActions
{
    [self openMenuActions];
    [self selectActionWithName:JMLocalizedString(@"action_title_markasfavorite")];
}

- (void)unmarkFromFavoritesFromMenuActions
{
    [self openMenuActions];
    [self selectActionWithName:JMLocalizedString(@"action_title_markasunfavorite")];
}

- (void)markAsFavoriteFromNavigationBar:(XCUIElement *)navigationBar
{
    // There isn't translation for this string
    [self tapButtonWithText:@"make favorite item"
              parentElement:navigationBar
                shouldCheck:YES];
}

- (void)unmarkFromFavoritesFromNavigationBar:(XCUIElement *)navigationBar
{
    // There isn't translation for this string
    [self tapButtonWithText:JMLocalizedString(@"menuitem_favorites_label")
              parentElement:navigationBar
                shouldCheck:YES];
}

#pragma mark - Helpers

- (void)unmarkFirstResource
{
    XCUIElement *firstItem = [self cellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                                  forIndex:0];
    [self unmarkItem:firstItem];

    [self unmarkAllFavoritesResourcesIfNeed];
}

- (void)unmarkItem:(XCUIElement *)favoriteItem
{
    [self openInfoPageFromCell:favoriteItem];

    [self openMenuActions];
    [self selectActionWithName:JMLocalizedString(@"action_title_markasunfavorite")];

    [self closeInfoPageFromCell];
}

@end
