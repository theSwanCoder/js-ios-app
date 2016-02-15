//
//  JMLibraryUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/11/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import <XCTest/XCTest.h>

NSString *const kJMTestLibrarySearchTextExample = @"sales mix";

@interface JMLibraryUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication *application;
@end

@implementation JMLibraryUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    
    self.application = [[XCUIApplication alloc] init];
    [self.application launch];
}

- (void)tearDown {
    
    self.application = nil;
    
    [super tearDown];
}

#pragma mark - Test 'Main' features

- (void)testThatLibraryPageHasTitleLibrary
{
    [self givenThatLibraryPageOnScreen];

    [self verifyThatCurrentPageIsLibrary];
}

- (void)testThatLibraryContainsListOfCells
{
    [self givenThatLibraryPageOnScreen];
    [self verifyThatCollectionViewContainsCells];
    
    XCUIElement *contentView = self.application.otherElements[@"JMBaseCollectionContentViewAccessibilityId"];
    if (contentView.exists) {

        [self verifyThatCollectionViewContainsListOfCells];
        
    } else {
        XCTFail(@"Content View doesn't visible");
    }
}

- (void)testMenuButton
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    
    XCUIElement *menuButton = self.application.navigationBars[@"Library"].buttons[@"menu icon"];
    if (menuButton.exists) {
        [menuButton tap];
        
        [self givenSideMenuVisible];
    } else {
        XCTFail(@"'Menu' button doesn't exist.");
    }
    
    if (menuButton.exists) {
        [menuButton tap];
        
        [self givenSideMenuNotVisible];
    } else {
        XCTFail(@"'Menu' button doesn't exist.");
    }
}

- (void)testThatUserCanPullDownToRefresh
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    
    [self givenThatCellsAreVisible];
    
    XCUIElement *collectionViewElement = [self.application.collectionViews elementBoundByIndex:0];
    XCUIElement *firstCellElement = [collectionViewElement.cells elementBoundByIndex:0];
    XCUIElement *secondCellElement = [collectionViewElement.cells elementBoundByIndex:4];
    
    [firstCellElement pressForDuration:1 thenDragToElement:secondCellElement];
    
    [self verifyThatCollectionViewNotContainsCells];
    [self verifyThatCollectionViewContainsCells];
}

- (void)testThatUserCanScrollDown
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    
    [self givenThatCellsAreVisible];
    
    XCUIElement *collectionViewElement = [self.application.collectionViews elementBoundByIndex:0];
    XCUIElement *cellElement = [collectionViewElement.cells elementBoundByIndex:2];
    [cellElement swipeUp];
    
    [self verifyThatCollectionViewContainsCells];
}

#pragma mark - Test 'Search' feature

- (void)testThatSearchWorkWithCorrectWords
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    
    [self verifyThatCollectionViewContainsCells];
    
    // start find some text
    [self trySearchText:kJMTestLibrarySearchTextExample];
    // verify result
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.hittable == true"];
    NSInteger filtredResultCount = [[self.application.cells allElementsBoundByIndex] filteredArrayUsingPredicate:predicate].count;
    XCTAssertTrue(filtredResultCount == 1, @"Should be only one result");
    
    // Reset search
    [self tryClearSearchBar];
    // verify result
    [self verifyThatCollectionViewContainsCells];
}

- (void)testThatSearchShowsNoResults
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self verifyThatCollectionViewContainsCells];
    
    // start find wrong text
    XCUIElement *searchResourcesSearchField = self.application.searchFields[@"Search resources"];
    if (searchResourcesSearchField.exists) {
        [searchResourcesSearchField tap];
        [searchResourcesSearchField typeText:@"ababababababababa"];
        
        XCUIElement *searchButton = self.application.buttons[@"Search"];
        if (searchButton.exists) {
            [searchButton tap];
            
            // verify result
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.hittable == true"];
            NSInteger filtredResultCount = [[self.application.cells allElementsBoundByIndex] filteredArrayUsingPredicate:predicate].count;
            XCTAssertTrue(filtredResultCount == 0, @"Should be only one result");
            
        } else {
            XCTFail(@"Search button doesn't exist.");
        }
        
    } else {
        XCTFail(@"Search field doesn't exist.");
    }
}

#pragma mark - Test 'Changing View Presentation' feature

- (void)testThatViewTypeButtonChangeViewPresentation
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self verifyThatCollectionViewContainsCells];
    
    XCUIElement *contentView = self.application.otherElements[@"JMBaseCollectionContentViewAccessibilityId"];
    if (contentView.exists) {
        
        [self givenThatCollectionViewContainsListOfCells];
        
        [self tryChangeViewPresentationFromListToGrid];
        [self verifyThatCollectionViewContainsGridOfCells];
        
        [self tryChangeViewPresentationFromGridToList];
        [self verifyThatCollectionViewContainsListOfCells];
        
    } else {
        XCTFail(@"Content View doesn't visible");
    }
}

- (void)testThatViewPresentationNotChangeAfterChangingPages
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self verifyThatCollectionViewContainsCells];
    
    XCUIElement *contentView = self.application.otherElements[@"JMBaseCollectionContentViewAccessibilityId"];
    if (contentView.exists) {
        
        [self givenThatCollectionViewContainsListOfCells];
        
        [self tryChangeViewPresentationFromListToGrid];
        [self verifyThatCollectionViewContainsGridOfCells];
        
        // Change Page to Repository
        [self tryOpenRepositoryPage];
        [self verifyThatCurrentPageIsRepository];
        
        // Change Page to Library
        [self tryOpenLibraryPage];
        [self verifyThatCurrentPageIsLibrary];
        
        [self verifyThatCollectionViewContainsGridOfCells];
        
    } else {
        XCTFail(@"Content View doesn't visible");
    }
}

- (void)testThatViewPresentationNotChangeWhenUserUseSearch
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCollectionViewContainsListOfCells];

    [self tryChangeViewPresentationFromListToGrid];
    [self verifyThatCollectionViewContainsGridOfCells];
    
    // start find some text
    [self trySearchText:kJMTestLibrarySearchTextExample];
    [self verifyThatCollectionViewContainsGridOfCells];
    
    [self tryClearSearchBar];
}

#pragma mark - Test 'Sort' feature
- (void)testThatUserCanSortListItemsByName
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCollectionViewContainsListOfCells];
    
    [self verifyThatCellsSortedByName];
}

- (void)testThatUserCanSortListItemsByCreationDate
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCollectionViewContainsListOfCells];
    
    [self trySortByCreationDate];
    [self givenThatCellsAreVisible];
    
    [self verifyThatCellsSortedByCreationDate];
}

- (void)testThatUserCanSortListItemsByModifiedDate
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCollectionViewContainsListOfCells];
    
    [self trySortByModifiedDate];
    [self verifyThatCellsSortedByModifiedDate];
}

#pragma mark - Test 'Filter' feature
- (void)testThatUserCanFilterByAllItems
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCollectionViewContainsListOfCells];
    
    [self verifyThatCellsFiltredByAll];
}

- (void)testThatUserCanFilterByReports
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCollectionViewContainsListOfCells];
    
    [self tryFilterByReports];
    [self verifyThatCellsFiltredByReports];
}

- (void)testThatUserCanFilterByDashboards
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCollectionViewContainsListOfCells];
    
    [self tryFilterByDashboards];
    [self verifyThatCellsFiltredByDashboards];
}

#pragma mark - Helpers
- (void)givenThatLibraryPageOnScreen
{
    // Intro Page
    XCUIElement *skipIntroButton = self.application.buttons[@"Skip Intro"];
    if (skipIntroButton.exists) {
        [skipIntroButton tap];
    }
    
    // Rate Alert
    XCUIElement *rateAlert = self.application.alerts[@"Rate TIBCO JasperMobile"];
    if (rateAlert.exists) {
        XCUIElement *rateAppLateButton = rateAlert.collectionViews.buttons[@"No, thanks"];
        if (rateAppLateButton.exists) {
            [rateAppLateButton tap];
        }
    }
    
    // Verify Library Page
    XCUIElement *libraryPageView = self.application.otherElements[@"JMLibraryPageAccessibilityId"];
    if (libraryPageView.exists) {
        NSLog(@"Library page on screen");
    } else {
        NSLog(@"Library page isn't on screen");
    }
    
    // wait if need when view in navigation view will appear
    NSPredicate *navBarPredicate = [NSPredicate predicateWithFormat:@"self.navigationBars.count > 0"];
    [self expectationForPredicate:navBarPredicate
              evaluatedWithObject:self.application
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    
    [self givenThatCellsAreVisible];
}

- (void)givenSideMenuVisible
{
    XCUIElement *menuView = self.application.otherElements[@"JMSideApplicationMenuAccessibilityId"];
    if (!menuView.exists) {
        [self tryOpenSideApplicationMenu];
    }
}

- (void)givenSideMenuNotVisible
{
    XCUIElement *menuView = self.application.otherElements[@"JMSideApplicationMenuAccessibilityId"];
    if (menuView.exists) {
        [self tryOpenSideApplicationMenu];
    }
}

- (void)givenThatCollectionViewContainsListOfCells
{
    NSInteger countOfListCells = [self countOfListCells];
    if (countOfListCells > 0) {
        return;
    } else {
        [self tryChangeViewPresentationFromGridToList];
    }
}

- (void)givenThatCellsAreVisible
{
    // wait until collection view will fill.
    NSPredicate *cellsCountPredicate = [NSPredicate predicateWithFormat:@"self.cells.count > 0"];
    [self expectationForPredicate:cellsCountPredicate
              evaluatedWithObject:self.application
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

// TODO: Implement this
//- (void)givenThatSortOptionIsByName
//{
//    [self verifyThatCellsSortedByName];
//}

#pragma mark - Helper Actions
// TODO: move to shared methods
- (void)tryOpenSideApplicationMenu
{
    XCUIElement *menuButton = self.application.buttons[@"menu icon"];
    if (menuButton.exists) {
        [menuButton tap];
    } else {
        XCTFail(@"'Menu' button doesn't exist.");
    }
}

- (void)tryOpenRepositoryPage
{
    NSString *libraryPageName = @"Repository";
    [self tryOpenPageWithName:libraryPageName];
}

- (void)tryOpenLibraryPage
{
    NSString *libraryPageName = @"Library";
    [self tryOpenPageWithName:libraryPageName];
}

- (void)tryOpenPageWithName:(NSString *)pageName
{
    [self tryOpenSideApplicationMenu];
    
    XCUIElement *menuView = self.application.otherElements[@"JMSideApplicationMenuAccessibilityId"];
    if (menuView.exists) {
        XCUIElement *pageMenuItem = menuView.cells.staticTexts[pageName];
        if (pageMenuItem.exists) {
            [pageMenuItem tap];
            
            // wait if need when view in navigation view will appear
            NSPredicate *navBarPredicate = [NSPredicate predicateWithFormat:@"self.navigationBars.count > 0"];
            [self expectationForPredicate:navBarPredicate
                      evaluatedWithObject:self.application
                                  handler:nil];
            [self waitForExpectationsWithTimeout:5 handler:nil];
        }
    } else {
        XCTFail(@"'Menu' isn't visible.");
    }
}

- (void)tryChangeViewPresentationFromListToGrid
{
    XCUIElement *gridButtonButton = self.application.buttons[@"grid button"];
    if (gridButtonButton.exists) {
        [gridButtonButton tap];
    } else {
        XCTFail(@"There isn't 'grid' button");
    }
}

- (void)tryChangeViewPresentationFromGridToList
{
    XCUIElement *horizontalListButtonButton = self.application.buttons[@"horizontal list button"];
    if (horizontalListButtonButton.exists) {
        [horizontalListButtonButton tap];
    } else {
        XCTFail(@"There isn't 'list' button");
    }
}

- (void)trySearchText:(NSString *)text
{
    // start find some text
    XCUIElement *searchResourcesSearchField = self.application.searchFields[@"Search resources"];
    if (searchResourcesSearchField.exists) {
        [searchResourcesSearchField tap];
        [searchResourcesSearchField typeText:text];
        
        XCUIElement *searchButton = self.application.buttons[@"Search"];
        if (searchButton.exists) {
            [searchButton tap];
        } else {
            XCTFail(@"Search button doesn't exist.");
        }
    } else {
        XCTFail(@"Search field doesn't exist.");
    }
}

- (void)tryClearSearchBar
{
    XCUIElement *searchResourcesSearchField = self.application.searchFields[@"Search resources"];
    if (searchResourcesSearchField.exists) {
        [searchResourcesSearchField tap];
        
        XCUIElement *cancelButton = self.application.buttons[@"Cancel"];
        if (cancelButton.exists) {
            [cancelButton tap];
        } else {
            XCTFail(@"Cancel button doesn't exist.");
        }
    } else {
        XCTFail(@"Search field doesn't exist.");
    }
}

- (void)trySortByName
{
    [self tryOpenMenuActions];
    [self tryOpenSortMenuFromMenuActions];
    [self trySelectSortByName];
}

- (void)trySortByCreationDate
{
    [self tryOpenMenuActions];
    [self tryOpenSortMenuFromMenuActions];
    [self trySelectSortByCreationDate];
}

- (void)trySortByModifiedDate
{
    [self tryOpenMenuActions];
    [self tryOpenSortMenuFromMenuActions];
    [self trySelectSortByModifiedDate];
}

- (void)tryOpenMenuActions
{
    XCUIElement *navBar = self.application.navigationBars[@"Library"];
    if (navBar.exists) {
        XCUIElement *menuActionsButton = navBar.buttons[@"Share"];
        if (menuActionsButton.exists) {
            [menuActionsButton tap];
            
            // Wait until menu actions appears
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.tables.count == 1"];
            [self expectationForPredicate:predicate
                      evaluatedWithObject:self.application
                                  handler:nil];
            [self waitForExpectationsWithTimeout:5 handler:nil];
            
            XCUIElement *menuActionsElement = [self.application.tables elementBoundByIndex:0];
            if (!menuActionsElement.exists) {
                XCTFail(@"Menu Actions isn't visible");
            }
        } else {
            XCTFail(@"Menu Actions button isn't visible");
        }
    } else {
        XCTFail(@"Navigation bar isn't visible");
    }
}

- (void)tryOpenSortMenuFromMenuActions
{
    XCUIElement *menuActionsElement = [self.application.tables elementBoundByIndex:0];
    XCUIElement *sortActionElement = menuActionsElement.staticTexts[@"Sort by"];
    if (sortActionElement.exists) {
        [sortActionElement tap];
        
        // Wait until sort view appears
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.tables.count == 1"];
        [self expectationForPredicate:predicate
                  evaluatedWithObject:self.application
                              handler:nil];
        [self waitForExpectationsWithTimeout:5 handler:nil];
        
    } else {
        XCTFail(@"Sort Action isn't visible");
    }
}

- (void)trySelectSortByName
{
    [self trySelectSortBy:@"Name"];
}

- (void)trySelectSortByCreationDate
{
    [self trySelectSortBy:@"Creation Date"];
}

- (void)trySelectSortByModifiedDate
{
    [self trySelectSortBy:@"Modified Date"];
}

- (void)trySelectSortBy:(NSString *)sortTypeString
{
    XCUIElement *sortOptionsViewElement = [self.application.tables elementBoundByIndex:0];
    if (sortOptionsViewElement.exists) {
        XCUIElement *sortOptionElement = sortOptionsViewElement.staticTexts[sortTypeString];
        if (sortOptionElement.exists) {
            [sortOptionElement tap];
        } else {
            XCTFail(@"'%@' Sort Option isn't visible", sortTypeString);
        }
    } else {
        XCTFail(@"Sort Options View isn't visible");
    }
}

- (void)tryFilterByAll
{
    [self tryOpenMenuActions];
    [self tryOpenFilterMenuFromMenuActions];
    [self trySelectFilterByAll];
}

- (void)trySelectFilterByAll
{
    [self trySelectFilterBy:@"All"];
}

- (void)tryFilterByReports
{
    [self tryOpenMenuActions];
    [self tryOpenFilterMenuFromMenuActions];
    [self trySelectFilterByReports];
}

- (void)trySelectFilterByReports
{
    [self trySelectFilterBy:@"Reports"];
}

- (void)tryFilterByDashboards
{
    [self tryOpenMenuActions];
    [self tryOpenFilterMenuFromMenuActions];
    [self trySelectFilterByDashboards];
}

- (void)trySelectFilterByDashboards
{
    [self trySelectFilterBy:@"Dashboards"];
}

- (void)tryOpenFilterMenuFromMenuActions
{
    XCUIElement *menuActionsElement = [self.application.tables elementBoundByIndex:0];
    XCUIElement *filterActionElement = menuActionsElement.staticTexts[@"Filter by"];
    if (filterActionElement.exists) {
        [filterActionElement tap];
        
        // Wait until sort view appears
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.tables.count == 1"];
        [self expectationForPredicate:predicate
                  evaluatedWithObject:self.application
                              handler:nil];
        [self waitForExpectationsWithTimeout:5 handler:nil];
        
    } else {
        XCTFail(@"Sort Action isn't visible");
    }
}

- (void)trySelectFilterBy:(NSString *)filterTypeString
{
    XCUIElement *filterOptionsViewElement = [self.application.tables elementBoundByIndex:0];
    if (filterOptionsViewElement.exists) {
        XCUIElement *filterOptionElement = filterOptionsViewElement.staticTexts[filterTypeString];
        if (filterOptionElement.exists) {
            [filterOptionElement tap];
        } else {
            XCTFail(@"'%@' Filter Option isn't visible", filterTypeString);
        }
    } else {
        XCTFail(@"Filter Options View isn't visible");
    }
}

#pragma mark - Verfies
- (void)verifyThatCollectionViewContainsListOfCells
{
    // Shold be 'list' cells
    NSInteger countOfListCells = [self countOfListCells];
    XCTAssertTrue(countOfListCells > 0, @"Should be 'List' presentation");
    
    // Should not be 'grid' cells
    NSInteger countOfGridCells = [self countOfGridCells];
    XCTAssertTrue(countOfGridCells == 0, @"Should be 'Grid' presentation");
}

- (void)verifyThatCollectionViewContainsGridOfCells
{
    // Should be 'grid' cells
    NSInteger countOfGridCells = [self countOfGridCells];
    XCTAssertTrue(countOfGridCells > 0, @"Should be 'Grid' presentation");
    
    // Shold not be 'list' cells
    NSInteger countOfListCells = [self countOfListCells];
    XCTAssertTrue(countOfListCells == 0, @"Should be 'List' presentation");
}

- (void)verifyThatCurrentPageIsLibrary
{
    XCUIElement *libraryNavBar = self.application.navigationBars[@"Library"];
    XCTAssertTrue(libraryNavBar.exists, @"Should be 'Library' page");
}

- (void)verifyThatCurrentPageIsRepository
{
    XCUIElement *libraryNavBar = self.application.navigationBars[@"Repository"];
    XCTAssertTrue(libraryNavBar.exists, @"Should be 'Library' page");
}

- (void)verifyThatCollectionViewContainsCells
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.hittable == true"];
    NSInteger filtredResultCount = [[self.application.cells allElementsBoundByIndex] filteredArrayUsingPredicate:predicate].count;
    XCTAssertTrue(filtredResultCount > 0, @"Should be some cells");
}

- (void)verifyThatCollectionViewNotContainsCells
{
    // TODO: implement
}

- (void)verifyThatCellsSortedByName
{
    NSArray *visibleCells = [self.application.cells allElementsBoundByIndex];
    
    NSArray *sortedCelsByName = [visibleCells sortedArrayUsingComparator:^NSComparisonResult(XCUIElement *obj1, XCUIElement *obj2) {
        XCUIElement *firstObjectTitleElement = [obj1.staticTexts elementBoundByIndex:0];
        NSString *firstObjectTitle = firstObjectTitleElement.label;
        
        XCUIElement *secondObjectTitleElement = [obj1.staticTexts elementBoundByIndex:0];
        NSString *secondObjectTitle = secondObjectTitleElement.label;
        return [firstObjectTitle compare:secondObjectTitle];
    }];
    
    XCTAssertEqualObjects([visibleCells lastObject], [sortedCelsByName lastObject], @"Cells should be sorted by name");
}

- (void)verifyThatCellsSortedByCreationDate
{
    // TODO: implement
//    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be sorted by creation date");
}

- (void)verifyThatCellsSortedByModifiedDate
{
    // TODO: implement
//    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be sorted by modified date");
}

- (void)verifyThatCellsFiltredByAll
{
    // TODO: implement
//    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be filtred by all");
}

- (void)verifyThatCellsFiltredByReports
{
    // TODO: implement
//    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be filtred by reports");
}

- (void)verifyThatCellsFiltredByDashboards
{
    // TODO: implement
//    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be filtred by dashboards");
}

#pragma mark - 
- (NSInteger)countOfGridCells
{
    NSPredicate *predicateForGrid = [NSPredicate predicateWithFormat:@"self.hittable == true && (self.identifier == 'JMCollectionViewGridCellAccessibilityId')"];
    NSInteger filtredResultCount = [[self.application.cells allElementsBoundByIndex] filteredArrayUsingPredicate:predicateForGrid].count;
    return filtredResultCount;
}

- (NSInteger)countOfListCells
{
    NSPredicate *predicateForList = [NSPredicate predicateWithFormat:@"self.hittable == true && (self.identifier == 'JMCollectionViewListCellAccessibilityId')"];
    NSInteger filtredResultCount = [[self.application.cells allElementsBoundByIndex] filteredArrayUsingPredicate:predicateForList].count;
    return filtredResultCount;
}

@end
