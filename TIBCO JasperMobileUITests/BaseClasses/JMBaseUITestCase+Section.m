//
// Created by Aleksandr Dakhno on 9/20/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+SideMenu.h"


@implementation JMBaseUITestCase (Section)

- (void)verifyPageTitle:(NSString *)title withPageAccessibilityId :(NSString *)accessibilityId
{
    XCUIElement *pageController = [self waitElementWithAccessibilityId:accessibilityId timeout:kUITestsBaseTimeout];
    NSString *pageTitle = pageController.label;
    if (![pageTitle isEqualToString:title]) {
        XCTFail(@"'%@' page's title doesn't correct", accessibilityId);
    }
}

#pragma mark - View Types
- (void)switchViewFromListToGridInSectionWithAccessibilityId:(NSString *)sectionAccessibilityId
{
    XCUIElement *parentElement = self.application;
    if (sectionAccessibilityId) {
        XCUIElement *sectionController = [self waitElementWithAccessibilityId:sectionAccessibilityId timeout:kUITestsBaseTimeout];
        NSString *sectionTitle = sectionController.label;
        parentElement = [self waitNavigationBarWithControllerAccessibilityId:sectionTitle
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
        parentElement = [self waitNavigationBarWithControllerAccessibilityId:sectionTitle
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
    XCUIElement *searchField = section.searchFields[JMResourceCollectionPageSearchBarPageAccessibilityId];
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
    NSInteger countOfCells = [self countOfGridCells];
    countOfCells += [self countOfListCells];
    XCTAssertTrue(countOfCells > 0, @"Collection view is empty");
}

- (void)verifyThatCollectionViewNotContainsCells
{
    // TODO: implement
}

#pragma mark - Helpers - Menu Sort By
- (void)selectSortBy:(NSString *)sortAccessibilityId
inSectionWithAccessibilityId:(NSString *)sectionAccessibilityId
{
    BOOL isActionsButtonExists = [self isActionsButtonExists];
    if (isActionsButtonExists) {
        [self selectMenuItem:JMMenuActionsViewSortActionAccessibilityId inSectionWithAccessibilityId:sectionAccessibilityId];
        
        XCUIElement *sortOptionsViewElement = self.application.otherElements[JMResourceCollectionPageSortByPopupViewPageAccessibilityId];
        if (sortOptionsViewElement.exists) {
            XCUIElement *sortOptionElement = sortOptionsViewElement.cells[sortAccessibilityId];
            if (sortOptionElement.exists) {
                [sortOptionElement tap];
            } else {
                XCTFail(@"'%@' Sort Option isn't visible", sortAccessibilityId);
            }
        } else {
            XCTFail(@"Sort Options View isn't visible");
        }
    }
}

#pragma mark - Menu Filter by
- (void)selectFilterBy:(NSString *)filterAccessibilityId
inSectionWithAccessibilityId:(NSString *)sectionAccessibilityId
{
    BOOL isActionsButtonExists = [self isActionsButtonExists];
    if (isActionsButtonExists) {
        [self selectMenuItem:JMMenuActionsViewFilterActionAccessibilityId inSectionWithAccessibilityId:sectionAccessibilityId];
        
        XCUIElement *filterOptionsViewElement = self.application.otherElements[JMResourceCollectionPageFilterByPopupViewPageAccessibilityId];
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

- (void)selectMenuItem:(NSString *)menuItemAccessibilityId inSectionWithAccessibilityId:(NSString *)accessibilityId
{
    [self openMenuActionsWithControllerAccessibilityId:accessibilityId];
    [self selectActionWithAccessibility:menuItemAccessibilityId];
}

#pragma mark - CollectionView

- (XCUIElement *)collectionViewElementFromSectionWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *section = [self waitElementWithAccessibilityId:accessibilityId
                                                        timeout:kUITestsBaseTimeout];
    return section;
}

@end
