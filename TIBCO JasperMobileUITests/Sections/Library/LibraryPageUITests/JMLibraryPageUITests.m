/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMLibraryPageUITests.h"
#import "JMLibraryPageUITests+Helpers.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+Search.h"
#import "XCUIElement+Tappable.h"

@implementation JMLibraryPageUITests

- (void)setUp
{
    [super setUp];

    [self givenThatLibraryPageOnScreen];
}

- (void)tearDown
{
    [self switchViewFromGridToListInSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];

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
    XCUIElement *navBar = [self findNavigationBarWithLabel:JMLocalizedString(@"menuitem_library_label")];
    if (!navBar.exists) {
        [self performTestFailedWithErrorMessage:[NSString stringWithFormat:@"Nav bar with %@ wasn't found", JMLocalizedString(@"menuitem_library_label")]
                                     logMessage:NSStringFromSelector(_cmd)];
    }
}

- (void)testThatLibraryContainsListOfCells
{
    [self givenThatCollectionViewContainsListOfCellsInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self verifyThatCollectionViewContainsListOfCells];
}

- (void)testMenuButton
{
    [self showSideMenuInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self hideSideMenuInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
}

- (void)testThatUserCanPullDownToRefresh
{
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];

    XCUIElement *collectionView = [self waitElementMatchingType:XCUIElementTypeCollectionView
                                                     identifier:@"JMBaseCollectionContentViewAccessibilityId"
                                                        timeout:0];
    XCUIElement *firstCellElement = [self elementMatchingType:XCUIElementTypeCell
                                                parentElement:collectionView
                                                      atIndex:0];
    XCUIElement *secondCellElement = [self elementMatchingType:XCUIElementTypeCell
                                                 parentElement:collectionView
                                                       atIndex:4];
    
    [firstCellElement pressForDuration:1
                     thenDragToElement:secondCellElement];

    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
}

- (void)testThatUserCanScrollDown
{
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];

    XCUIElement *collectionView = [self waitElementMatchingType:XCUIElementTypeCollectionView
                                                     identifier:@"JMBaseCollectionContentViewAccessibilityId"
                                                        timeout:0];
    XCUIElement *cellElement = [self elementMatchingType:XCUIElementTypeCell
                                           parentElement:collectionView
                                                 atIndex:2];
    [cellElement swipeUp];

    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
}

#pragma mark - Test 'Search' feature

- (void)testThatSearchWorkWithCorrectWords
{
    [self performSearchResourceWithName:kJMTestLibrarySearchTextExample
                      inSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];

    NSInteger cellsCount = [self countOfListCells];
    XCTAssertTrue(cellsCount > 0, @"Should one or more results");

    [self clearSearchResultInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
}

- (void)testThatSearchShowsNoResults
{
    [self performSearchResourceWithName:@"ababababababababa"
                      inSectionWithName:JMLocalizedString(@"menuitem_library_label")];


    XCUIElement *loadingLabel = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                         text:@"Loading."
                                                parentElement:nil
                                          shouldBeInHierarchy:NO
                                                      timeout:kUITestsBaseTimeout];
    if (loadingLabel.exists) {
        [self performTestFailedWithErrorMessage:@"There shouldn't be 'Loading. Please wait...' label"
                                     logMessage:[NSString stringWithFormat:@"All static texts: %@", self.application.staticTexts.allElementsBoundByAccessibilityElement]];
    }

    XCUIElement *noResultLabel = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                          text:JMLocalizedString(@"resources_noresults_msg")
                                                       timeout:kUITestsBaseTimeout];
    if (!noResultLabel.exists) {
        [self performTestFailedWithErrorMessage:@"There isn't 'No Results.' label"
                                     logMessage:[NSString stringWithFormat:@"All static texts: %@", self.application.staticTexts.allElementsBoundByAccessibilityElement]];
    }

    [self clearSearchResultInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
}

#pragma mark - Test 'Changing View Presentation' feature

- (void)testThatViewTypeButtonChangeViewPresentation
{
    [self givenThatCollectionViewContainsListOfCellsInSectionWithName:JMLocalizedString(@"menuitem_library_label")];

    [self switchViewFromListToGridInSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self verifyThatCollectionViewContainsGridOfCells];

    [self switchViewFromGridToListInSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self verifyThatCollectionViewContainsListOfCells];
}

- (void)testThatViewPresentationNotChangeAfterChangingPages
{
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
}

- (void)testThatViewPresentationNotChangeWhenUserUseSearch
{
    [self givenThatCollectionViewContainsListOfCellsInSectionWithName:JMLocalizedString(@"menuitem_library_label")];

    [self switchViewFromListToGridInSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
    [self verifyThatCollectionViewContainsGridOfCells];
    
    // start find some text
    [self performSearchResourceWithName:kJMTestLibrarySearchTextExample
                      inSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];

    [self verifyThatCollectionViewContainsGridOfCells];

    [self clearSearchResultInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
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
