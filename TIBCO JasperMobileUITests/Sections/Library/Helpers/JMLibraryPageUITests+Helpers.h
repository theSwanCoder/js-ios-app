//
// Created by Aleksandr Dakhno on 2/18/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMLibraryPageUITests.h"

@interface JMLibraryPageUITests (Helpers)
// Helpers - Main
- (void)givenThatCollectionViewContainsListOfCells;
// Helpers - Collection View Presentations
- (void)tryChangeViewPresentationFromListToGrid;
- (void)tryChangeViewPresentationFromGridToList;
// Helpers - Search
- (void)trySearchText:(NSString *)text;
- (void)tryClearSearchBar;
// Helpers - Menu Sort By
- (void)tryOpenSortMenu;
- (void)tryOpenSortMenuFromMenuActions;
- (void)tryOpenSortMenuFromNavBar;
// Helpers - Menu Filter By
- (void)tryOpenFilterMenu;
- (void)tryOpenMenuActions;
- (void)tryOpenFilterMenuFromMenuActions;
- (void)tryOpenFilterMenuFromNavBar;
// Helpers - Sort By
- (void)trySortByName;
- (void)trySortByCreationDate;
- (void)trySortByModifiedDate;
- (void)trySelectSortBy:(NSString *)sortTypeString;
// Helpers - Filter By
- (void)tryFilterByAll;
- (void)tryFilterByReports;
- (void)tryFilterByDashboards;
- (void)trySelectFilterBy:(NSString *)filterTypeString;
// Verfies
- (void)verifyThatCollectionViewContainsListOfCells;
- (void)verifyThatCollectionViewContainsGridOfCells;
//- (void)verifyThatCurrentPageIsLibrary;
//- (void)verifyThatCurrentPageIsRepository;
- (void)verifyThatCollectionViewContainsCells;
- (void)verifyThatCollectionViewNotContainsCells;
- (void)verifyThatCellsSortedByName;
- (void)verifyThatCellsSortedByCreationDate;
- (void)verifyThatCellsSortedByModifiedDate;
- (void)verifyThatCellsFiltredByAll;
- (void)verifyThatCellsFiltredByReports;
- (void)verifyThatCellsFiltredByDashboards;
- (NSInteger)countOfGridCells;
- (NSInteger)countOfListCells;
@end