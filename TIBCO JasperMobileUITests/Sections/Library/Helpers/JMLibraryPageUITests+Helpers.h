//
// Created by Aleksandr Dakhno on 2/18/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMLibraryPageUITests.h"

@interface JMLibraryPageUITests (Helpers)
// Helpers - Search
- (void)trySearchText:(NSString *)text;
- (void)tryClearSearchBar;

// Verfies
- (void)verifyThatCellsSortedByName;
- (void)verifyThatCellsSortedByCreationDate;
- (void)verifyThatCellsSortedByModifiedDate;
- (void)verifyThatCellsFiltredByAll;
- (void)verifyThatCellsFiltredByReports;
- (void)verifyThatCellsFiltredByDashboards;
@end
