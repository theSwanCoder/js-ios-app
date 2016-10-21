//
// Created by Aleksandr Dakhno on 9/20/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+SideMenu.h"


@implementation JMBaseUITestCase (Section)

#pragma mark - View Types
- (void)switchViewFromListToGridInSectionWithAccessibilityId:(NSString *)sectionAccessibilityId
{
    XCUIElement *parentElement = self.application;
    if (sectionAccessibilityId) {
        XCUIElement *sectionController = [self waitElementWithAccessibilityId:sectionAccessibilityId timeout:kUITestsBaseTimeout];
        NSString *sectionTitle = sectionController.label;
        parentElement = [self waitNavigationBarWithLabel:sectionTitle
                                                 timeout:kUITestsBaseTimeout];
    }
    XCUIElement *gridButton = [self findButtonWithAccessibilityId:JMResourceCollectionPageGridRepresentationButtonViewPageAccessibilityId
                                                    parentElement:parentElement];
    if (gridButton) {
        [gridButton tap];
    }
}

- (void)switchViewFromGridToListInSectionWithAccessibilityId:(NSString *)sectionAccessibilityId
{
    XCUIElement *parentElement = self.application;
    if (sectionAccessibilityId) {
        XCUIElement *sectionController = [self waitElementWithAccessibilityId:sectionAccessibilityId timeout:kUITestsBaseTimeout];
        NSString *sectionTitle = sectionController.label;
        parentElement = [self waitNavigationBarWithLabel:sectionTitle
                                                 timeout:kUITestsBaseTimeout];
    }
    XCUIElement *listButton = [self findButtonWithAccessibilityId:JMResourceCollectionPageListRepresentationButtonViewPageAccessibilityId
                                                    parentElement:parentElement];
    if (listButton) {
        [listButton tap];
    }
}

#pragma mark - Search
- (void)searchResourceWithName:(NSString *)resourceName
  inSectionWithAccessibilityId:(NSString *)sectionAccessibilityId
{
    XCUIElement *searchResourcesSearchField = [self searchFieldFromSectionWithAccessibilityId:sectionAccessibilityId];
    [searchResourcesSearchField tap];

    XCUIElement *clearTextButton = [self findButtonWithAccessibilityId:@"Clear text"
                                               parentElement:searchResourcesSearchField];
    if (clearTextButton) {
        [clearTextButton tap];
    }

    [searchResourcesSearchField typeText:resourceName];

    XCUIElement *searchButton = [self waitButtonWithAccessibilityId:@"Search"
                                                            timeout:kUITestsBaseTimeout];
    [searchButton tap];
}

- (void)searchResourceWithName:(NSString *)resourceName inSectionWithName:(NSString *)sectionName
{
    if ([sectionName isEqualToString:JMLibraryPageAccessibilityId]) {
        [self openLibrarySection];
        // TODO: replace with specific element - JMLibraryPageAccessibilityId
        [self searchResourceWithName:resourceName
        inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
    } else if ([sectionName isEqualToString:JMRepositoryPageAccessibilityId]) {
        [self openRepositorySection];
        // TODO: replace with specific element - JMRepositoryPageAccessibilityId
        [self searchResourceWithName:resourceName
        inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
    } else if ([sectionName isEqualToString:JMFavoritesPageAccessibilityId]) {
        [self openFavoritesSection];
        // TODO: replace with specific element - JMRepositoryPageAccessibilityId
        [self searchResourceWithName:resourceName
        inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
    } else {
        XCTFail(@"Wrong section for searching test dashboard: %@", sectionName);
    }
}

- (void)clearSearchResultInSectionWithAccessibilityId:(NSString *)sectionAccessibilityId
{
    XCUIElement *searchResourcesSearchField = [self searchFieldFromSectionWithAccessibilityId:sectionAccessibilityId];
    [searchResourcesSearchField tap];

    XCUIElement *clearTextButton = [self findButtonWithAccessibilityId:@"Clear text"
                                               parentElement:searchResourcesSearchField];
    if (clearTextButton) {
        [clearTextButton tap];
    }

    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"Cancel"
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

- (XCUIElement *)searchFieldFromSectionWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *section = [self waitElementWithAccessibilityId:accessibilityId
                                                        timeout:kUITestsBaseTimeout];
    XCUIElement *searchField = section.searchFields[@"Search resources"];
    [self waitElementReady:searchField
                   timeout:kUITestsBaseTimeout];
    return searchField;
}

#pragma mark - Cells
- (NSInteger)countOfGridCells
{
    NSInteger countOfListCells = 0;
    NSArray *listCellsIdentifiers = @[JMResourceCollectionPageGridLoadingCellAccessibilityId,
                                      JMResourceCollectionPageFileResourceGridCellAccessibilityId,
                                      JMResourceCollectionPageFolderResourceGridCellAccessibilityId,
                                      JMResourceCollectionPageHTMLSavedItemsResourceGridCellAccessibilityId,
                                      JMResourceCollectionPagePDFSavedItemsResourceGridCellAccessibilityId,
                                      JMResourceCollectionPageXLSSavedItemsResourceGridCellAccessibilityId,
                                      JMResourceCollectionPageReportResourceGridCellAccessibilityId,
                                      JMResourceCollectionPageHTMLTempExportedResourceGridCellAccessibilityId,
                                      JMResourceCollectionPagePDFTempExportedResourceGridCellAccessibilityId,
                                      JMResourceCollectionPageXLSTempExportedResourceGridCellAccessibilityId,
                                      JMResourceCollectionPageDashboardResourceGridCellAccessibilityId,
                                      JMResourceCollectionPageLegacyDashboardResourceGridCellAccessibilityId,
                                      JMResourceCollectionPageScheduleResourceGridCellAccessibilityId];
    for (NSString *cellIdentifier in listCellsIdentifiers) {
        countOfListCells += [self countCellsWithAccessibilityId:cellIdentifier];
    }
    
    return countOfListCells;
}

- (NSInteger)countOfListCells
{
    NSInteger countOfListCells = 0;
    NSArray *listCellsIdentifiers = @[JMResourceCollectionPageListLoadingCellAccessibilityId,
                                      JMResourceCollectionPageFileResourceListCellAccessibilityId,
                                      JMResourceCollectionPageFolderResourceListCellAccessibilityId,
                                      JMResourceCollectionPageHTMLSavedItemsResourceListCellAccessibilityId,
                                      JMResourceCollectionPagePDFSavedItemsResourceListCellAccessibilityId,
                                      JMResourceCollectionPageXLSSavedItemsResourceListCellAccessibilityId,
                                      JMResourceCollectionPageReportResourceListCellAccessibilityId,
                                      JMResourceCollectionPageHTMLTempExportedResourceListCellAccessibilityId,
                                      JMResourceCollectionPagePDFTempExportedResourceListCellAccessibilityId,
                                      JMResourceCollectionPageXLSTempExportedResourceListCellAccessibilityId,
                                      JMResourceCollectionPageDashboardResourceListCellAccessibilityId,
                                      JMResourceCollectionPageLegacyDashboardResourceListCellAccessibilityId,
                                      JMResourceCollectionPageScheduleResourceListCellAccessibilityId];
    for (NSString *cellIdentifier in listCellsIdentifiers) {
        countOfListCells += [self countCellsWithAccessibilityId:cellIdentifier];
    }

    return countOfListCells;
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

- (void)verifyThatCollectionViewContainsCells
{
    NSArray *allCells = [self.application.cells allElementsBoundByAccessibilityElement];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(XCUIElement  * _Nullable cell, NSDictionary<NSString *,id> * _Nullable bindings) {
        return cell.exists == true && cell.isHittable == true;
    }];
    NSInteger filtredResultCount = [allCells filteredArrayUsingPredicate:predicate].count;
    XCTAssertTrue(filtredResultCount > 0, @"Should be some cells");
}

- (void)verifyThatCollectionViewNotContainsCells
{
    // TODO: implement
}

#pragma mark - Helpers - Menu Sort By

- (void)openSortMenuInSectionWithTitle:(NSString *)sectionTitle
{
    BOOL isActionsButtonExists = [self isActionsButtonExists];
    if (isActionsButtonExists) {
        [self openMenuActionsWithControllerAccessibilityId:sectionTitle];
        [self tryOpenSortMenuFromMenuActions];
    } else {
        [self tryOpenSortMenuFromNavBarWithTitle:sectionTitle];
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

#pragma mark - Menu Filter by
- (void)selectFilterBy:(NSString *)filterAccessibilityId
inSectionWithAccessibilityId:(NSString *)sectionAccessibilityId
{
    BOOL isActionsButtonExists = [self isActionsButtonExists];
    if (isActionsButtonExists) {
        [self openFilterMenuInSectionWithAccessibilityId:sectionAccessibilityId];
        
        XCUIElement *filterOptionsViewElement = self.application.tables[JMResourceCollectionPageFilterByPopupViewPageAccessibilityId];
        if (filterOptionsViewElement.exists) {
            XCUIElement *filterOptionElement = filterOptionsViewElement.cells[filterAccessibilityId];
            if (filterOptionElement.exists) {
                [filterOptionElement tap];
            } else {
                XCTFail(@"'%@' Filter Option isn't visible", filterAccessibilityId);
            }
        } else {
            XCTFail(@"Filter Options View isn't visible");
        }
    }
}

- (void)openFilterMenuInSectionWithAccessibilityId:(NSString *)accessibilityId
{
    [self openMenuActionsWithControllerAccessibilityId:accessibilityId];
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

#pragma mark - CollectionView

- (XCUIElement *)collectionViewElementFromSectionWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *section = [self waitElementWithAccessibilityId:accessibilityId
                                                        timeout:kUITestsBaseTimeout];
    return section;
}

@end
