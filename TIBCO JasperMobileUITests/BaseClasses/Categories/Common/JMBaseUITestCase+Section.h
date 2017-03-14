/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Section)

// View Types
- (void)switchViewFromListToGridInSectionWithTitle:(NSString *)sectionTitle;
- (void)switchViewFromGridToListInSectionWithTitle:(NSString *)sectionTitle;

// Cells
- (void)givenThatCollectionViewContainsListOfCellsInSectionWithName:(NSString *)sectionName;
- (void)givenThatCollectionViewContainsGridOfCellsInSectionWithName:(NSString *)sectionName;
- (NSInteger)countOfGridCells;
- (NSInteger)countOfListCells;

- (void)waitCollectionViewContainsCellsWithTimeout:(NSTimeInterval)timeout;

- (void)verifyThatCollectionViewContainsListOfCells;
- (void)verifyThatCollectionViewContainsGridOfCells;

// Sort Action
//- (void)openSortMenuInSectionWithTitle:(NSString *)sectionTitle;
- (void)selectSortBy:(NSString *)sortTypeString
  inSectionWithTitle:(NSString *)sectionTitle;

// Filter Action
//- (void)openFilterMenuInSectionWithTitle:(NSString *)sectionTitle;
- (void)selectFilterBy:(NSString *)filterTypeString
    inSectionWithTitle:(NSString *)sectionTitle;

// CollectionView
- (XCUIElement *)collectionViewElementFromSectionWithAccessibilityId:(NSString *)accessibilityId;

// Verifying
- (void)verifyThatSectionOnScreenWithTitle:(NSString *)sectionTitle;

// Sections
- (XCUIElement *)libraryPageViewElement;
- (void)givenThatLibraryPageOnScreen;
- (void)givenThatRepositoryPageOnScreen;
@end
