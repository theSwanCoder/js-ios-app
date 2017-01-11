//
//  JMFavoritePageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMFavoritePageUITests.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+Favorites.h"
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+Dashboard.h"
#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+Search.h"

@implementation JMFavoritePageUITests

#pragma mark - JMBaseUITestCaseProtocol

- (NSInteger)testsCount
{
    return 15;
}

#pragma mark - Tests
    
//    User should see Favorites screen
//    - Steps:
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Results:
//      - User should see Favorites screen
- (void)testThatUserCanSeeFavoritesPage
{
    [self openFavoritesSectionIfNeed];

    [self verifyThatFavoritePageOnScreen];
}

//    Left Panel button
//    - Steps:
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Results:
//      - User should see Left Panel (side menu) button on the Favorites screen
- (void)testThatFavoritesPageHasSideMenuButton
{
    [self openFavoritesSectionIfNeed];
    
    [self verifyThatFavoritePageHasSideMenuButton];
}

//    Favorites title
//    - Steps:
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Results:
//      - User should see title like “Favorites”
- (void)testThatUserFavoritesPageHasCorrectTitle
{
    [self openFavoritesSectionIfNeed];
    
    [self verifyThatFavoritePageHasCorrectTitle];
}

//    Search result
//    - Preconditions:
//      - Make a test report as favorite
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Verify searching operations
//    - Results:
//      - User can:
//      - enter search text
//      - edit search text
//      - delete search text
//      - cancel search
//      - see result after success searching
//    - After:
//      - Unmark the test report from favorites
- (void)testThatSearchWorkCorrectly
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_reportUnit")
      inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self markTestReportAsFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_library_label")];

    [self performSearchResourceWithName:kTestReportName
                      inSectionWithName:JMLocalizedString(@"menuitem_favorites_label")];
    [self givenThatReportCellsOnScreenInSectionWithName:JMLocalizedString(@"menuitem_favorites_label")];

    [self unmarkTestReportFromFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_favorites_label")];
}

//    Error message when no search result
//    - Preconditions:
//      - Make a test report as favorite
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Enter in search field a text don’t related to the test report
//    - Results:
//      - Message ‘No search result’ instead of favorite items
//    - After:
//      - Unmark the test report from favorites
- (void)testThatSearchWithEmptyResultShowCorrectMessage
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_reportUnit")
      inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self markTestReportAsFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_library_label")];

    [self performSearchResourceWithName:@"Search without result text"
                      inSectionWithName:JMLocalizedString(@"menuitem_favorites_label")];

    [self verifyThatCorrectMessageAppearForEmptyResult];

    [self unmarkTestReportFromFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_favorites_label")];
}

//    View type button
//    - Preconditions:
//      - Make a test report as favorite
//      - Open the Left Panel
//      - Tap on the Favorites button
//      - View Type is set to ‘List’
//    - Steps(1):
//      - Set View Type to ‘Grid’
//    - Results(1):
//      - Verify that cells look like in grid.
//    - Steps(2):
//      - Move to Library
//      - Back to Favorite
//    - Results(2):
//      - Verify that cells looks like in grid.
//    - Steps(3):
//      - Move to Repository
//      - Set View Type to ‘List’ (if need)
//      - Mark a test folder as favorite
//      - Back to Favorites
//      - Open the favorite test folder
//    - Results(3):
//      - Items in the folder look like in grid
//    - After:
//      - Unmark the test report from favorites
//      - Unmark the test folder from favorites
- (void)testThatViewTypeButtonWorkCorrectly
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_reportUnit")
      inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self markTestReportAsFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_library_label")];

    [self openFavoritesSectionIfNeed];

    [self switchViewFromListToGridInSectionWithTitle:JMLocalizedString(@"menuitem_favorites_label")];
    [self verifyThatCollectionViewContainsGridOfCells];

    [self openLibrarySectionIfNeed];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
    [self verifyThatCollectionViewContainsListOfCells];

    [self openFavoritesSectionIfNeed];
    [self verifyThatCollectionViewContainsGridOfCells];

    [self switchViewFromGridToListInSectionWithTitle:JMLocalizedString(@"menuitem_favorites_label")];

    [self unmarkTestReportFromFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_favorites_label")];
}

//    Sorting button
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Select sorting by Name
//      - Select sorting by Creation Date
//      - Select sorting by Modified Date
//      - Verify that sorting options don’t save when user leave Favorites screen
//    - Results:
//      - Sorting dialog should appear
//      - User can sorted by Name
//      - User can sorted by Creation Date
//      - User can sorted by Modified Date
- (void)testThatSortingWorkCorrectly
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_reportUnit")
      inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self markTestReportAsFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_library_label")];

    [self openFavoritesSectionIfNeed];
    
    [self selectSortBy:JMLocalizedString(@"resources_sortby_name")
    inSectionWithTitle:JMLocalizedString(@"menuitem_favorites_label")];
    [self verifyThatCollectionViewContainsListOfCells];
    
    [self selectSortBy:JMLocalizedString(@"resources_sortby_creationDate")
    inSectionWithTitle:JMLocalizedString(@"menuitem_favorites_label")];
    [self verifyThatCollectionViewContainsListOfCells];
    
    [self selectSortBy:@"Modified Date"
    inSectionWithTitle:JMLocalizedString(@"menuitem_favorites_label")];
    [self verifyThatCollectionViewContainsListOfCells];

    [self unmarkTestReportFromFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_favorites_label")];
}

//    Filter button
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap Filter button
//      - Select filter by All
//      - Select filter by Reports
//      - Select filter by Saved Items
//      - Select filter by Dashboards
//      - Select filter by Folders
//      - Select filter by Content Resources
//      - Verify that filter options don’t save when user leave Favorites screen
//    - Results:
//      - Filter dialog should appear
//      - User can see all items
//      - User can see only reports
//      - User can see only saved items
//      - User can see only dashboards
//      - User can see only folders
//      - User can see only content resources
- (void)testThatFilteringWorkCorrectly
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_reportUnit")
      inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self markTestReportAsFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_library_label")];

    [self openFavoritesSectionIfNeed];
    [self verifyThatCollectionViewContainsListOfCells];
    
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_reportUnit")
    inSectionWithTitle:JMLocalizedString(@"menuitem_favorites_label")];
    [self verifyThatCollectionViewContainsListOfCells];
    
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_saved_reportUnit")
    inSectionWithTitle:JMLocalizedString(@"menuitem_favorites_label")];
    [self verifyThatCorrectMessageAppearForEmptyResult];
    
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_dashboard")
    inSectionWithTitle:JMLocalizedString(@"menuitem_favorites_label")];
    [self verifyThatCorrectMessageAppearForEmptyResult];
    
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_folder")
    inSectionWithTitle:JMLocalizedString(@"menuitem_favorites_label")];
    [self verifyThatCorrectMessageAppearForEmptyResult];
    
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_files")
    inSectionWithTitle:JMLocalizedString(@"menuitem_favorites_label")];
    [self verifyThatCorrectMessageAppearForEmptyResult];
    
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_all")
      inSectionWithTitle:JMLocalizedString(@"menuitem_favorites_label")];

    [self unmarkTestReportFromFavoriteFromSectionWithName:@"Favorites"];
}

- (void)verifyThatCorrectMessageAppearForEmptyResult
{
    XCUIElement *element = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                    text:@"No Favorited Items"
                                                 timeout:kUITestsBaseTimeout];
    if (!element.exists) {
        XCTFail(@"Label 'No Favorited Items' wasn't found");
    }
}

//    Pull down to refresh all items
//    - Preconditions:
//      - Make a test report as favorite
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Pull down to refresh
//    - Results:
//      - Favorites screen should refresh
//    - After:
//      - Unmark the test report from favorites
- (void)testThatRefreshWorkByUsingPullDown
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_reportUnit")
      inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self markTestReportAsFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_dashboard")
      inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self markTestDashboardAsFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_library_label")];

    [self openFavoritesSectionIfNeed];

    [self performPullDownToRefresh];

    [self unmarkTestReportFromFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_favorites_label")];
    [self unmarkTestDashboardFromFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_favorites_label")];
}

//    Scrolling of the list/grid
//    - Preconditions:
//      - Make a test report as favorite
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Scroll the list
//      - Scroll the grid
//    - Results:
//      - Scroll should work as expected
//    - After:
//      - Unmark the test report from favorites
- (void)testThatScrollingWorkCorreclty
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_reportUnit")
      inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self markTestReportAsFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_library_label")];

    [self openFavoritesSectionIfNeed];

    [self performSwipeToScrool];

    [self unmarkTestReportFromFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_favorites_label")];
}

//    User should see only favorites items which he/she added they
//    - Steps:
//      - Open the Left Panel
//      - Tap on the Settings button
//      - Tap on current active server’s name
//      - Tap on any server connection
//      - Login as ‘joeuser’
//      - Open the Left Panel
//      - Tap on the Repository button
//      - Add some reports/dashboards/folders to favorites
//      - Open the Left Panel
//      - Tap on the Setting button
//      - Tap on current active server’s name
//      - Tap on any server connection
//      - Login as ‘jasperadmin’
//      - Open Favorites screen
//    - Results:
//      - Jasperadmin shouldn’t see favorite items which were added by ‘joeuser’
- (void)testThatFavoriteItemsVisibleOnlyOwner
{
    // TODO: implement the test after implementing working with accounts
}

//    JRS 6.0/6.0.1/6.1: Report Thumbnails
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Library button
//      - Add some reports to favorites
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Don’t run the part of the reports
//      - Run the part of the reports
//    - Results:
//      - User should see default placeholder for reports which weren’t run.
//      - User should see Report Thumbnails for reports which were run.
- (void)testThatReportThumbnailsVisible
{
    // It's difficult to implement, because after opening a report - thumbnail will be always available
}

//    Remove button on the report
//    - Preconditions:
//      - Make a test report as favorite
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap on report info
//      - Tap on ‘Remove From Favorites’ button
//    - Results:
//      - Report should be removed
- (void)testThatFavoriteReportCanBeUnmarkedFromFavorites
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_reportUnit")
      inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self markTestReportAsFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_library_label")];

    [self openFavoritesSectionIfNeed];

    [self unmarkTestReportFromFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_favorites_label")];
}

//    Remove button on the dashboard
//    - Preconditions:
//      - Make a test dashboard as favorite
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap on report info
//      - Tap on ‘Remove From Favorites’ button
//    - Results:
//      - Test dashboard should be removed
- (void)testThatFavoriteDashboardCanBeUnmarkedFromFavorites
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_dashboard")
      inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self markTestDashboardAsFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_library_label")];

    [self openFavoritesSectionIfNeed];

    [self unmarkTestDashboardFromFavoriteFromSectionWithName:JMLocalizedString(@"menuitem_favorites_label")];
}
    
//    Remove button on the folder
//    - Preconditions:
//      - Make a test folder as favorite
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap on report info
//      - Tap on ‘Remove From Favorites’ button
//    - Results:
//      - Test folder should be removed
- (void)testThatFavoriteFolderCanBeUnmarkedFromFavorites
{
    // TODO: implement after covering 'repositories'
}

#pragma mark - Verifying

- (void)verifyThatFavoritePageOnScreen
{
    // TODO: replace with specific element - JMFavoritesPageAccessibilityId
    XCUIElement *element = [self waitElementMatchingType:XCUIElementTypeOther
                                              identifier:@"JMBaseCollectionContentViewAccessibilityId"
                                                 timeout:kUITestsBaseTimeout];
    if (!element.exists) {
        XCTFail(@"Favorite page wasn't found");
    }
}

- (void)verifyThatFavoritePageHasSideMenuButton
{
    XCUIElement *menuButton = [self findMenuButtonOnNavBarWithTitle:JMLocalizedString(@"menuitem_favorites_label")];
    if (!menuButton || !menuButton.exists) {
        XCTFail(@"There isn't menu button");
    }
}

- (void)verifyThatFavoritePageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:JMLocalizedString(@"menuitem_favorites_label")
                             timeout:kUITestsBaseTimeout];
}

#pragma mark - Helpers

- (void)performPullDownToRefresh
{
    XCUIElement *collectionViewElement = [self collectionViewElementFromSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];

    XCUIElement *firstCellElement = [collectionViewElement.cells elementBoundByIndex:0];
    XCUIElement *secondCellElement = [collectionViewElement.cells elementBoundByIndex:1];

    [firstCellElement pressForDuration:1
                     thenDragToElement:secondCellElement];
}

- (void)performSwipeToScrool
{
    XCUIElement *collectionViewElement = [self collectionViewElementFromSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
    XCUIElement *cellElement = [collectionViewElement.cells elementBoundByIndex:0];
    [cellElement swipeUp];
}

@end
