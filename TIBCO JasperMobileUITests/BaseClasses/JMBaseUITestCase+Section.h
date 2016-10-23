//
// Created by Aleksandr Dakhno on 9/20/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Section)

- (void)verifyPageTitle:(NSString *)title withPageAccessibilityId:(NSString *)accessibilityId;

// View Types
- (void)switchViewFromListToGridInSectionWithAccessibilityId:(NSString *)sectionAccessibilityId;
- (void)switchViewFromGridToListInSectionWithAccessibilityId:(NSString *)sectionAccessibilityId;

// Search
- (void)searchResourceWithName:(NSString *)resourceName
  inSectionWithAccessibilityId:(NSString *)sectionAccessibilityId;
- (void)clearSearchResultInSectionWithAccessibilityId:(NSString *)sectionAccessibilityId;

// Cells
- (NSInteger)countOfGridCells;
- (NSInteger)countOfListCells;
- (void)verifyThatCollectionViewContainsCells;
- (void)verifyThatCollectionViewNotContainsCells;
- (void)verifyThatCollectionViewContainsListOfCells;
- (void)verifyThatCollectionViewContainsGridOfCells;

// Sort Action
- (void)selectSortBy:(NSString *)sortAccessibilityId inSectionWithAccessibilityId:(NSString *)sectionAccessibilityId;

// Filter Action
- (void)selectFilterBy:(NSString *)filterAccessibilityId inSectionWithAccessibilityId:(NSString *)sectionAccessibilityId;

// CollectionView
- (XCUIElement *)collectionViewElementFromSectionWithAccessibilityId:(NSString *)accessibilityId;

@end
