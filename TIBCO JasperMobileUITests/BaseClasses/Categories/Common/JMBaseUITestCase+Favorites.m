//
// Created by Aleksandr Dakhno on 10/3/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

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
    [self selectFilterBy:@"All"
      inSectionWithTitle:@"Favorites"];
    [self switchViewFromGridToListInSectionWithTitle:@"Favorites"];
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
    [self selectActionWithName:@"Mark as Favorite"];
}

- (void)unmarkFromFavoritesFromMenuActions
{
    [self openMenuActions];
    [self selectActionWithName:@"Remove From Favorites"];
}

- (void)markAsFavoriteFromNavigationBar:(XCUIElement *)navigationBar
{
    [self tapButtonWithText:@"make favorite item"
              parentElement:navigationBar
                shouldCheck:YES];
}

- (void)unmarkFromFavoritesFromNavigationBar:(XCUIElement *)navigationBar
{
    [self tapButtonWithText:@"favorited item"
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
    [self selectActionWithName:@"Remove From Favorites"];

    [self closeInfoPageFromCell];
}

@end
