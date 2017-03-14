/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMLibraryPageUITests.h"

@interface JMLibraryPageUITests (Helpers)
// Helpers - Sort By
- (void)trySortByName;
- (void)trySortByCreationDate;
- (void)trySortByModifiedDate;
// Helpers - Filter By
- (void)tryFilterByReports;
- (void)tryFilterByDashboards;
// Verfies
- (void)verifyThatCellsSortedByName;
- (void)verifyThatCellsSortedByCreationDate;
- (void)verifyThatCellsSortedByModifiedDate;
- (void)verifyThatCellsFiltredByAll;
- (void)verifyThatCellsFiltredByReports;
- (void)verifyThatCellsFiltredByDashboards;
@end
