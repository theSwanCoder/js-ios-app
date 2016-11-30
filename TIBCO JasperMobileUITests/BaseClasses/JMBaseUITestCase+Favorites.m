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


@implementation JMBaseUITestCase (Favorites)

- (void)givenThatFavoritesSectionIsEmpty
{
    [self openFavoritesSection];
    [self selectFilterBy:@"All"
      inSectionWithTitle:@"Favorites"];
    [self switchViewFromGridToListInSectionWithTitle:@"Favorites"];
    [self unmarkAllFavoritesResourcesIfNeed];
    [self openLibrarySection];
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
    XCUIElement *favoriteButton = [self waitButtonWithAccessibilityId:@"make favorite item"
                                                        parentElement:navigationBar
                                                              timeout:kUITestsBaseTimeout];
    [favoriteButton tap];
}

- (void)unmarkFromFavoritesFromNavigationBar:(XCUIElement *)navigationBar
{
    XCUIElement *favoriteButton = [self waitButtonWithAccessibilityId:@"favorited item"
                                                        parentElement:navigationBar
                                                              timeout:kUITestsBaseTimeout];
    [favoriteButton tap];
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
