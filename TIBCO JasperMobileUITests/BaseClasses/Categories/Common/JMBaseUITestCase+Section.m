/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+OtherElements.h"
#import "JMBaseUITestCase+Buttons.h"
#import "XCUIElement+Tappable.h"
#import "JMBaseUITestCase+Cells.h"


@implementation JMBaseUITestCase (Section)

#pragma mark - View Types
- (void)switchViewFromListToGridInSectionWithTitle:(NSString *)sectionTitle
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:sectionTitle
                                                   timeout:kUITestsBaseTimeout];
    [self tapButtonWithText:@"grid button" // We don't have translation for this button
              parentElement:navBar
                shouldCheck:NO];
}

- (void)switchViewFromGridToListInSectionWithTitle:(NSString *)sectionTitle
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:sectionTitle
                                                   timeout:kUITestsBaseTimeout];
    [self tapButtonWithText:@"horizontal list button" // We don't have translation for this button
              parentElement:navBar
                shouldCheck:NO];
}

#pragma mark - Cells

- (void)givenThatCollectionViewContainsListOfCellsInSectionWithName:(NSString *)sectionName
{
    [self switchViewFromGridToListInSectionWithTitle:sectionName];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
}

- (void)givenThatCollectionViewContainsGridOfCellsInSectionWithName:(NSString *)sectionName
{
    [self switchViewFromListToGridInSectionWithTitle:sectionName];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
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
    NSInteger waitingInterval = 1;
    BOOL countMoreThanZero = [self isCountOfCollectionViewCellsMoreThanZero];
    BOOL condition = (remain > 0) && !countMoreThanZero;
    while ( condition ) {
        remain -= kUITestsElementAvailableTimeout;
        sleep(waitingInterval);
        countMoreThanZero = [self isCountOfCollectionViewCellsMoreThanZero];
        condition = (remain > 0) && !countMoreThanZero;
        NSLog(@"remain: %@", @(remain));
    }

    if (!countMoreThanZero) {
        XCTFail(@"Cells weren't found");
    }
}

- (BOOL)isCountOfCollectionViewCellsMoreThanZero
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    XCUIElement *collectionView = [self waitElementMatchingType:XCUIElementTypeOther
                                                     identifier:@"JMBaseCollectionContentViewAccessibilityId"
                                                        timeout:0];
    if (!collectionView.exists) {
        [self performTestFailedWithErrorMessage:@"Collection view wasn't found"
                                     logMessage:NSStringFromSelector(_cmd)];
    }

    NSArray <XCUIElement *>* allCells = collectionView.cells.allElementsBoundByAccessibilityElement;
    for (XCUIElement *cell in allCells) {
        BOOL isExists = cell.exists;
        if (isExists) {
            BOOL isHittable = [cell respondsToSelector:@selector(isHittable)] && cell.isHittable;
            if (isHittable) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - Helpers - Menu Sort By

- (void)selectSortBy:(NSString *)sortTypeString
  inSectionWithTitle:(NSString *)sectionTitle
{
    [self openSortMenuInSectionWithTitle:sectionTitle];
    [self selectSortBy:sortTypeString];
}

- (void)selectSortBy:(NSString *)sortTypeString
{
    // TODO: replace with element id
    XCUIElement *menuView = [self elementMatchingType:XCUIElementTypeTable
                                        parentElement:nil
                                              atIndex:0];
    if (!menuView.exists) {
        XCTFail(@"Sort Options View isn't visible");
    }

    XCUIElement *sortActionElement = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                              text:sortTypeString
                                                     parentElement:menuView
                                                           timeout:0];
    if (sortActionElement.exists) {
        [sortActionElement tapByWaitingHittable];
    } else {
        XCTFail(@"'%@' Sort Option isn't visible", sortTypeString);
    }
}

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

- (void)tryOpenSortMenuFromMenuActions
{
    // TODO: replace with element id
    XCUIElement *sortOptionsView = [self elementMatchingType:XCUIElementTypeTable
                                                parentElement:nil
                                                      atIndex:0];
    if (!sortOptionsView.exists) {
        XCTFail(@"Sort Options View isn't visible");
    }

    XCUIElement *sortActionElement = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                              text:JMLocalizedString(@"action_title_sort")
                                                     parentElement:sortOptionsView
                                                           timeout:0];
    if (sortActionElement.exists) {
        [sortActionElement tapByWaitingHittable];

        [self verifySortMenuDidAppear];
    } else {
        XCTFail(@"Sort Action isn't visible");
    }
}

- (void)tryOpenSortMenuFromNavBarWithTitle:(NSString *)navBarTitle
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:navBarTitle
                                                   timeout:kUITestsBaseTimeout];
    [self tapButtonWithText:@"sort action" // We don't have translation for this button
              parentElement:navBar
                shouldCheck:YES];
}

#pragma mark - Menu Filter by

- (void)selectFilterBy:(NSString *)filterTypeString
    inSectionWithTitle:(NSString *)sectionTitle
{
    [self openFilterMenuInSectionWithTitle:sectionTitle];
    [self selectFilterBy:filterTypeString];
}

- (void)selectFilterBy:(NSString *)filterTypeString
{
    // TODO: replace with element id
    XCUIElement *menuView = [self elementMatchingType:XCUIElementTypeTable
                                        parentElement:nil
                                              atIndex:0];
    if (!menuView.exists) {
        XCTFail(@"Resource Types View isn't visible");
    }

    XCUIElement *filterOptionElement = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                                text:filterTypeString
                                                       parentElement:menuView
                                                             timeout:0];
    if (filterOptionElement.exists) {
        [filterOptionElement tapByWaitingHittable];
    } else {
        XCTFail(@"'%@' Filter Option isn't visible", filterTypeString);
    }
}

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
    // TODO: replace with element id
    XCUIElement *resourceTypeView = [self elementMatchingType:XCUIElementTypeTable
                                                parentElement:nil
                                                      atIndex:0];
    if (!resourceTypeView.exists) {
        XCTFail(@"Resource Types View isn't visible");
    }

    XCUIElement *filterActionElement = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                                text:JMLocalizedString(@"action_title_filter")
                                                       parentElement:resourceTypeView
                                                             timeout:0];
    if (filterActionElement.exists) {
        [filterActionElement tapByWaitingHittable];

        [self verifyFiltersMenuDidAppear];
    } else {
        XCTFail(@"Sort Action isn't visible");
    }
}

- (void)tryOpenFilterMenuFromNavBarWithTitle:(NSString *)navBarTitle
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:navBarTitle
                                                   timeout:kUITestsBaseTimeout];
    [self tapButtonWithText:@"filter action" // We don't have translation for this button
              parentElement:navBar
                shouldCheck:YES];
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

- (void)verifyFiltersMenuDidAppear
{
    XCUIElement *filtersMenu = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                        text:JMLocalizedString(@"resources_filterby_title")
                                               parentElement:nil
                                                     timeout:kUITestsElementAvailableTimeout];
    if (!filtersMenu.exists) {
        [self performTestFailedWithErrorMessage:@"Filters menu wasn't found"
                                     logMessage:NSStringFromSelector(_cmd)];
    }
}

- (void)verifySortMenuDidAppear
{
    XCUIElement *sortMenu = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                     text:JMLocalizedString(@"resources_sortby_title")
                                            parentElement:nil
                                                  timeout:kUITestsElementAvailableTimeout];
    if (!sortMenu.exists) {
        [self performTestFailedWithErrorMessage:@"Sort menu wasn't found"
                                     logMessage:NSStringFromSelector(_cmd)];
    }
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
    [self waitNavigationBarWithLabel:JMLocalizedString(@"menuitem_repository_label")
                             timeout:kUITestsBaseTimeout];
}

@end
