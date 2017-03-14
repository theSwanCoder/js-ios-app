/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMLibraryPageUITests+Helpers.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+Dashboard.h"
#import "XCUIElement+Tappable.h"


@implementation JMLibraryPageUITests (Helpers)

#pragma mark - Helpers - Sort By

- (void)trySortByName
{
    [self selectSortBy:JMLocalizedString(@"resources_sortby_name")
    inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
}

- (void)trySortByCreationDate
{
    [self selectSortBy:JMLocalizedString(@"resources_sortby_creationDate")
    inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
}

- (void)trySortByModifiedDate
{
    [self selectSortBy:JMLocalizedString(@"resources_sortby_modifiedDate")
    inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
}

#pragma mark - Helpers - Filter By


- (void)tryFilterByReports
{
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_reportUnit")
      inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
}

- (void)tryFilterByDashboards
{
    [self selectFilterBy:JMLocalizedString(@"resources_filterby_type_dashboard")
      inSectionWithTitle:JMLocalizedString(@"menuitem_library_label")];
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
