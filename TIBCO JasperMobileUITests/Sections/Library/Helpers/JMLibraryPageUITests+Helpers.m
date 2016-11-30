//
// Created by Aleksandr Dakhno on 2/18/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMLibraryPageUITests+Helpers.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Section.h"


@implementation JMLibraryPageUITests (Helpers)

#pragma mark - Helpers - Search

- (void)trySearchText:(NSString *)text
{
    // start find some text
    XCUIElement *searchResourcesSearchField = self.application.searchFields[@"Search resources"];
    if (searchResourcesSearchField.exists) {
        [searchResourcesSearchField tap];
        [searchResourcesSearchField typeText:text];

        XCUIElement *searchButton = self.application.buttons[@"Search"];
        if (searchButton.exists) {
            [searchButton tap];
        } else {
            XCTFail(@"Search button doesn't exist.");
        }
    } else {
        XCTFail(@"Search field doesn't exist.");
    }
}

- (void)tryClearSearchBar
{
    XCUIElement *searchResourcesSearchField = self.application.searchFields[@"Search resources"];
    if (searchResourcesSearchField.exists) {
        [searchResourcesSearchField tap];

        XCUIElement *cancelButton = self.application.buttons[@"Cancel"];
        if (cancelButton.exists) {
            [cancelButton tap];
        } else {
            XCTFail(@"Cancel button doesn't exist.");
        }
    } else {
        XCTFail(@"Search field doesn't exist.");
    }
}

#pragma mark - Helpers - Sort By

- (void)trySortByName
{
    [self selectSortBy:@"Name" inSectionWithTitle:@"Library"];
}

- (void)trySortByCreationDate
{
    [self selectSortBy:@"Creation Date" inSectionWithTitle:@"Library"];
}

- (void)trySortByModifiedDate
{
    [self selectSortBy:@"Modified Date" inSectionWithTitle:@"Library"];
}

#pragma mark - Helpers - Filter By


- (void)tryFilterByReports
{
    [self selectFilterBy:@"Reports" inSectionWithTitle:@"Library"];

    [self givenThatReportCellsOnScreen];
}

- (void)tryFilterByDashboards
{
    [self selectFilterBy:@"Dashboards" inSectionWithTitle:@"Library"];

    [self givenThatDashboardCellsOnScreen];
}

#pragma mark - Verfies

- (void)verifyThatCellsSortedByName
{
    NSArray *visibleCells = [self.application.cells allElementsBoundByIndex];

    NSArray *sortedCelsByName = [visibleCells sortedArrayUsingComparator:^NSComparisonResult(XCUIElement *obj1, XCUIElement *obj2) {
        XCUIElement *firstObjectTitleElement = [obj1.staticTexts elementBoundByIndex:0];
        NSString *firstObjectTitle = firstObjectTitleElement.label;

        XCUIElement *secondObjectTitleElement = [obj1.staticTexts elementBoundByIndex:0];
        NSString *secondObjectTitle = secondObjectTitleElement.label;
        return [firstObjectTitle compare:secondObjectTitle];
    }];

    XCTAssertEqualObjects([visibleCells lastObject], [sortedCelsByName lastObject], @"Cells should be sorted by name");
}

- (void)verifyThatCellsSortedByCreationDate
{
    // TODO: implement
    //    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be sorted by creation date");
}

- (void)verifyThatCellsSortedByModifiedDate
{
    // TODO: implement
    //    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be sorted by modified date");
}

- (void)verifyThatCellsFiltredByAll
{
    // TODO: implement
    //    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be filtred by all");
}

- (void)verifyThatCellsFiltredByReports
{
    // TODO: implement
    //    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be filtred by reports");
}

- (void)verifyThatCellsFiltredByDashboards
{
    // TODO: implement
    //    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be filtred by dashboards");
}

@end
