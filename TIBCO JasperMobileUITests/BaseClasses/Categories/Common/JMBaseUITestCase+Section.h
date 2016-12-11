//
// Created by Aleksandr Dakhno on 9/20/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

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
- (void)verifyThatCollectionViewContainsCells;
- (void)verifyThatCollectionViewNotContainsCells;
- (void)verifyThatCollectionViewContainsListOfCells;
- (void)verifyThatCollectionViewContainsGridOfCells;

// Sort Action
- (void)openSortMenuInSectionWithTitle:(NSString *)sectionTitle;
- (void)selectSortBy:(NSString *)sortTypeString
  inSectionWithTitle:(NSString *)sectionTitle;

// Filter Action
- (void)openFilterMenuInSectionWithTitle:(NSString *)sectionTitle;
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
