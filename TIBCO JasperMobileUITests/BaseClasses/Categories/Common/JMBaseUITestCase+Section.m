//
// Created by Aleksandr Dakhno on 9/20/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+OtherElements.h"
#import "JMBaseUITestCase+Buttons.h"


@implementation JMBaseUITestCase (Section)

#pragma mark - View Types
- (void)switchViewFromListToGridInSectionWithTitle:(NSString *)sectionTitle
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:sectionTitle
                                                   timeout:kUITestsBaseTimeout];
    [self tapButtonWithText:@"grid button"
              parentElement:navBar
                shouldCheck:NO];
}

- (void)switchViewFromGridToListInSectionWithTitle:(NSString *)sectionTitle
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:sectionTitle
                                                   timeout:kUITestsBaseTimeout];
    [self tapButtonWithText:@"horizontal list button"
              parentElement:navBar
                shouldCheck:NO];
}

#pragma mark - Cells

- (void)givenThatCollectionViewContainsListOfCellsInSectionWithName:(NSString *)sectionName
{
    [self switchViewFromGridToListInSectionWithTitle:sectionName];
}

- (void)givenThatCollectionViewContainsGridOfCellsInSectionWithName:(NSString *)sectionName
{
    [self switchViewFromListToGridInSectionWithTitle:sectionName];
}

- (NSInteger)countOfGridCells
{
    return [self countCellsWithAccessibilityId:@"JMCollectionViewGridCellAccessibilityId"];
}

- (NSInteger)countOfListCells
{
    return [self countCellsWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"];
}

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

- (void)waitCollectionViewContainsCellsWithTimeout:(NSTimeInterval)timeout
{
    NSTimeInterval remain = timeout;
    BOOL countMoreThanZero;
    do {
        remain -= kUITestsElementAvailableTimeout;
        sleep(kUITestsElementAvailableTimeout);
        countMoreThanZero = [self countAllActiveCells] > 0;
        NSLog(@"remain: %@", @(remain));
    } while ( remain >= 0 && !countMoreThanZero);

    if (!countMoreThanZero) {
        XCTFail(@"Cells weren't found");
    }
}

- (NSInteger)countAllActiveCells
{
    NSArray *allCells = [self.application.cells allElementsBoundByAccessibilityElement];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(XCUIElement  * _Nullable cell, NSDictionary<NSString *,id> * _Nullable bindings) {
        return cell.exists == true && cell.isHittable == true;
    }];
    return [allCells filteredArrayUsingPredicate:predicate].count;
}

#pragma mark - Helpers - Menu Sort By

- (void)openSortMenuInSectionWithTitle:(NSString *)sectionTitle
{
    BOOL isShareButtonExists = [self isShareButtonExists];
    if (isShareButtonExists) {
        [self openMenuActions];
        [self tryOpenSortMenuFromMenuActions];
    } else {
        [self tryOpenSortMenuFromNavBarWithTitle:sectionTitle];
    }
}

- (void)selectSortBy:(NSString *)sortTypeString inSectionWithTitle:(NSString *)sectionTitle
{
    [self openSortMenuInSectionWithTitle:sectionTitle];
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

- (void)tryOpenSortMenuFromNavBarWithTitle:(NSString *)navBarTitle
{
    XCUIElement *navBar = self.application.navigationBars[navBarTitle];
    if (navBar.exists) {
        XCUIElement *sortButton = navBar.buttons[@"sort action"];
        if (sortButton.exists) {
            [sortButton tap];
        } else {
            XCTFail(@"Sort Button isn't visible");
        }
    } else {
        XCTFail(@"Navigation bar isn't visible");
    }
}

#pragma mark - Menu Filter by

- (void)openFilterMenuInSectionWithTitle:(NSString *)sectionTitle
{
    BOOL isShareButtonExists = [self isShareButtonExists];
    if (isShareButtonExists) {
        [self openMenuActions];
        [self tryOpenFilterMenuFromMenuActions];
    } else {
        [self tryOpenFilterMenuFromNavBarWithTitle:sectionTitle];
    }
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

- (void)tryOpenFilterMenuFromNavBarWithTitle:(NSString *)navBarTitle
{
    XCUIElement *navBar = self.application.navigationBars[navBarTitle];
    if (navBar.exists) {
        XCUIElement *filterButton = navBar.buttons[@"filter action"];
        if (filterButton.exists) {
            [filterButton tap];
        } else {
            XCTFail(@"Filter Button isn't visible");
        }
    } else {
        XCTFail(@"Navigation bar isn't visible");
    }
}

- (void)selectFilterBy:(NSString *)filterTypeString
    inSectionWithTitle:(NSString *)sectionTitle
{
    [self openFilterMenuInSectionWithTitle:sectionTitle];

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

#pragma mark - CollectionView

- (XCUIElement *)collectionViewElementFromSectionWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *section = [self waitElementMatchingType:XCUIElementTypeOther
                                              identifier:accessibilityId
                                                 timeout:kUITestsBaseTimeout];
    return section;
}

#pragma mark - Verifying

- (void)verifyThatSectionOnScreenWithTitle:(NSString *)sectionTitle
{
    [self waitNavigationBarWithLabel:sectionTitle
                             timeout:kUITestsBaseTimeout];
}

#pragma mark - Sections

- (XCUIElement *)libraryPageViewElement
{
    XCUIElement *element = [self waitElementMatchingType:XCUIElementTypeOther
                                              identifier:@"JMBaseCollectionContentViewAccessibilityId"
                                                 timeout:0];
    return element;
}

- (void)givenThatLibraryPageOnScreen
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    // Verify Library Page
    [self verifyThatCurrentPageIsLibrary];
}

- (void)givenThatRepositoryPageOnScreen
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self verifyThatCurrentPageIsRepository];
}


- (void)verifyThatCurrentPageIsLibrary
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    // TODO: replace with specific element - JMLibraryPageAccessibilityId
    [self verifyThatElementWithIdExist:@"JMBaseCollectionContentViewAccessibilityId"];
}

- (void)verifyThatCurrentPageIsRepository
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *repositoryNavBar = self.application.navigationBars[@"Repository"];
    NSPredicate *repositoryPagePredicate = [NSPredicate predicateWithFormat:@"self.exists == true"];

    [self expectationForPredicate:repositoryPagePredicate
              evaluatedWithObject:repositoryNavBar
                          handler:nil];
    [self waitForExpectationsWithTimeout:kUITestsBaseTimeout
                                 handler:nil];
}

@end