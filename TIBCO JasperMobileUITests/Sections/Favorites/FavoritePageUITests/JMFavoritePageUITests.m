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

@implementation JMFavoritePageUITests

#pragma mark - Tests
    
//    User should see Favorites screen
//    - Steps:
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Results:
//      - User should see Favorites screen
- (void)testThatUserCanSeeFavoritesPage
{
    [self openFavoritesSection];

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
    [self openFavoritesSection];
    
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
    [self openFavoritesSection];
    
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
    
    [self selectFilterBy:@"Reports"
      inSectionWithTitle:@"Library"];
    [self markTestReportAsFavoriteFromSectionWithName:@"Library"];

    [self openFavoritesSection];
    [self givenThatReportCellsOnScreen];
    
    [self searchResourceWithName:kTestReportName
    inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];

    [self givenThatCellsAreVisible];

    [self unmarkTestReportFromFavoriteFromSectionWithName:@"Favorites"];
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
    
    [self selectFilterBy:@"Reports"
      inSectionWithTitle:@"Library"];
    [self markTestReportAsFavoriteFromSectionWithName:@"Library"];
    
    [self openFavoritesSection];
    [self searchResourceWithName:@"Search without result text"
    inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];

    [self verifyThatCorrectMessageAppearForEmptyResult];

    [self unmarkTestReportFromFavoriteFromSectionWithName:@"Favorites"];
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
    
    [self selectFilterBy:@"Reports"
      inSectionWithTitle:@"Library"];
    [self markTestReportAsFavoriteFromSectionWithName:@"Library"];

    [self openFavoritesSection];

    [self switchViewFromListToGridInSectionWithTitle:@"Favorites"];
    [self verifyThatCollectionViewContainsGridOfCells];

    [self openLibrarySection];
    [self givenThatCellsAreVisible];
    [self verifyThatCollectionViewContainsListOfCells];
    
    [self openFavoritesSection];
    [self verifyThatCollectionViewContainsGridOfCells];

    [self switchViewFromGridToListInSectionWithTitle:@"Favorites"];

    [self unmarkTestReportFromFavoriteFromSectionWithName:@"Favorites"];
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
    
    [self selectFilterBy:@"Reports"
      inSectionWithTitle:@"Library"];
    [self markTestReportAsFavoriteFromSectionWithName:@"Library"];
    
    [self openFavoritesSection];
    
    [self selectSortBy:@"Name"
    inSectionWithTitle:@"Favorites"];
    [self verifyThatCollectionViewContainsListOfCells];
    
    [self selectSortBy:@"Creation Date"
    inSectionWithTitle:@"Favorites"];
    [self verifyThatCollectionViewContainsListOfCells];
    
    [self selectSortBy:@"Modified Date"
    inSectionWithTitle:@"Favorites"];
    [self verifyThatCollectionViewContainsListOfCells];

    [self unmarkTestReportFromFavoriteFromSectionWithName:@"Favorites"];
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
    
    [self selectFilterBy:@"Reports"
      inSectionWithTitle:@"Library"];
    [self markTestReportAsFavoriteFromSectionWithName:@"Library"];
    
    [self openFavoritesSection];
    [self verifyThatCollectionViewContainsListOfCells];
    
    [self selectFilterBy:@"Reports"
    inSectionWithTitle:@"Favorites"];
    [self verifyThatCollectionViewContainsListOfCells];
    
    [self selectFilterBy:@"Saved Items"
    inSectionWithTitle:@"Favorites"];
    [self verifyThatCorrectMessageAppearForEmptyResult];
    
    [self selectFilterBy:@"Dashboards"
    inSectionWithTitle:@"Favorites"];
    [self verifyThatCorrectMessageAppearForEmptyResult];
    
    [self selectFilterBy:@"Folders"
    inSectionWithTitle:@"Favorites"];
    [self verifyThatCorrectMessageAppearForEmptyResult];
    
    [self selectFilterBy:@"Content Resources"
    inSectionWithTitle:@"Favorites"];
    [self verifyThatCorrectMessageAppearForEmptyResult];
    
    [self selectFilterBy:@"All"
      inSectionWithTitle:@"Favorites"];

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
    
    [self selectFilterBy:@"Reports"
      inSectionWithTitle:@"Library"];
    [self markTestReportAsFavoriteFromSectionWithName:@"Library"];
    [self selectFilterBy:@"Dashboards"
      inSectionWithTitle:@"Library"];
    [self markTestDashboardAsFavoriteFromSectionWithName:@"Library"];

    [self openFavoritesSection];

    [self performPullDownToRefresh];

    [self unmarkTestReportFromFavoriteFromSectionWithName:@"Favorites"];
    [self unmarkTestDashboardFromFavoriteFromSectionWithName:@"Favorites"];
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
    
    [self selectFilterBy:@"Reports"
      inSectionWithTitle:@"Library"];
    [self markTestReportAsFavoriteFromSectionWithName:@"Library"];

    [self openFavoritesSection];

    [self performSwipeToScrool];

    [self unmarkTestReportFromFavoriteFromSectionWithName:@"Favorites"];
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
    
    [self selectFilterBy:@"Reports"
      inSectionWithTitle:@"Library"];
    [self markTestReportAsFavoriteFromSectionWithName:@"Library"];
    
    [self openFavoritesSection];

    [self unmarkTestReportFromFavoriteFromSectionWithName:@"Favorites"];
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
    
    [self selectFilterBy:@"Dashboards"
      inSectionWithTitle:@"Library"];
    [self markTestDashboardAsFavoriteFromSectionWithName:@"Library"];
    
    [self openFavoritesSection];

    [self unmarkTestDashboardFromFavoriteFromSectionWithName:@"Favorites"];
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
    XCUIElement *navBar = [self findNavigationBarWithLabel:@"Favorites"];
    XCUIElement *menuButton = [self findMenuButtonOnParentElement:navBar];
    if (!menuButton || !menuButton.exists) {
        XCTFail(@"There isn't menu button");
    }
}

- (void)verifyThatFavoritePageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:@"Favorites"
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
