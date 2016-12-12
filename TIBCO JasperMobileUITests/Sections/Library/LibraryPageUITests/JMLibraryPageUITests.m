//
//  JMLibraryUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/11/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMLibraryPageUITests.h"
#import "JMLibraryPageUITests+Helpers.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+Search.h"

@implementation JMLibraryPageUITests

- (void)setUp
{
    [super setUp];

    [self givenThatLibraryPageOnScreen];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
}

- (void)tearDown
{

    [super tearDown];
}

#pragma mark - JMBaseUITestCaseProtocol

- (NSInteger)testsCount
{
    return 16;
}

#pragma mark - Test 'Main' features

- (void)testThatLibraryPageHasCorrectTitle
{
    // verify that library page has correct title
}

- (void)testThatLibraryContainsListOfCells
{
    [self givenThatCollectionViewContainsListOfCellsInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    
    XCUIElement *contentView = self.application.otherElements[@"JMBaseCollectionContentViewAccessibilityId"];
    if (contentView.exists) {

        [self verifyThatCollectionViewContainsListOfCells];
        
    } else {
        XCTFail(@"Content View doesn't visible");
    }
}

- (void)testMenuButton
{
    [self showSideMenuInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self hideSideMenuInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
}

- (void)testThatUserCanPullDownToRefresh
{
    XCUIElement *collectionViewElement = [self.application.collectionViews elementBoundByIndex:0];
    XCUIElement *firstCellElement = [collectionViewElement.cells elementBoundByIndex:0];
    XCUIElement *secondCellElement = [collectionViewElement.cells elementBoundByIndex:4];
    
    [firstCellElement pressForDuration:1
                     thenDragToElement:secondCellElement];

    // TODO: implement by detecting 'loading' cell
//    [self verifyThatCollectionViewNotContainsCells];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
}

- (void)testThatUserCanScrollDown
{
    XCUIElement *collectionViewElement = [self.application.collectionViews elementBoundByIndex:0];
    XCUIElement *cellElement = [collectionViewElement.cells elementBoundByIndex:2];
    [cellElement swipeUp];

    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
}

#pragma mark - Test 'Search' feature

- (void)testThatSearchWorkWithCorrectWords
{
    // start find some text
    [self switchViewFromGridToListInSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self givenThatReportCellsOnScreenInSectionWithName:JMLocalizedString(@"menuitem_library_label")];

    [self performSearchResourceWithName:kJMTestLibrarySearchTextExample
                      inSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    NSInteger cellsCount = [self countOfListCells];
    XCTAssertTrue(cellsCount > 0, @"Should one or more results");

    // Reset search
    [self tryClearSearchBar];
    // verify result
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
}

- (void)testThatSearchShowsNoResults
{
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
            XCTAssertTrue(filtredResultCount == 0, @"Should not be any results");
            
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
    XCUIElement *contentView = self.application.otherElements[@"JMBaseCollectionContentViewAccessibilityId"];
    if (contentView.exists) {
        
        [self givenThatCollectionViewContainsListOfCellsInSectionWithName:JMLocalizedString(@"menuitem_library_label")];

        [self switchViewFromListToGridInSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
        [self verifyThatCollectionViewContainsGridOfCells];

        [self switchViewFromGridToListInSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
        [self verifyThatCollectionViewContainsListOfCells];
        
    } else {
        XCTFail(@"Content View doesn't visible");
    }
}

- (void)testThatViewPresentationNotChangeAfterChangingPages
{
    XCUIElement *contentView = self.application.otherElements[@"JMBaseCollectionContentViewAccessibilityId"];
    if (contentView.exists) {
        
        [self givenThatCollectionViewContainsListOfCellsInSectionWithName:JMLocalizedString(@"menuitem_library_label")];

        [self switchViewFromListToGridInSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
        [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
        [self verifyThatCollectionViewContainsGridOfCells];
        
        // Change Page to Repository
        [self openRepositorySectionIfNeed];
        [self givenThatRepositoryPageOnScreen];
        
        // Change Page to Library
        [self openLibrarySectionIfNeed];
        [self givenThatLibraryPageOnScreen];
        [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
        
        [self verifyThatCollectionViewContainsGridOfCells];
        
    } else {
        XCTFail(@"Content View doesn't visible");
    }
}

- (void)testThatViewPresentationNotChangeWhenUserUseSearch
{
    [self givenThatCollectionViewContainsListOfCellsInSectionWithName:JMLocalizedString(@"menuitem_library_label")];

    [self switchViewFromListToGridInSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self verifyThatCollectionViewContainsGridOfCells];
    
    // start find some text
    [self trySearchText:kJMTestLibrarySearchTextExample];
    [self verifyThatCollectionViewContainsGridOfCells];
    
    [self tryClearSearchBar];
}

#pragma mark - Test 'Sort' feature
- (void)testThatUserCanSortListItemsByName
{
    [self trySortByName];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];

    [self verifyThatCellsSortedByName];
}

- (void)testThatUserCanSortListItemsByCreationDate
{
    [self trySortByCreationDate];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
    
    [self verifyThatCellsSortedByCreationDate];
}

- (void)testThatUserCanSortListItemsByModifiedDate
{
    [self trySortByModifiedDate];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];

    [self verifyThatCellsSortedByModifiedDate];
}

#pragma mark - Test 'Filter' feature
- (void)testThatUserCanFilterByAllItems
{
    [self givenThatLibraryPageOnScreen];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
    
    [self verifyThatCellsFiltredByAll];
}

- (void)testThatUserCanFilterByReports
{
    [self tryFilterByReports];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
    [self verifyThatCellsFiltredByReports];
}

- (void)testThatUserCanFilterByDashboards
{
    [self tryFilterByDashboards];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
    [self verifyThatCellsFiltredByDashboards];
}

@end
