/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMBaseUITestCase+Cells.h"
#import "JMBaseUITestCase+Helpers.h"


@implementation JMBaseUITestCase (Cells)

- (NSInteger)countCellsWithAccessibilityId:(NSString *)accessibilityId
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSPredicate *identifierPredicate = [NSPredicate predicateWithFormat:@"%K like %@", @"identifier", accessibilityId];
    XCUIElementQuery *cellsQuery = [self.application.cells matchingPredicate:identifierPredicate];
    NSArray *allCells = cellsQuery.allElementsBoundByAccessibilityElement;
    return allCells.count;
}

- (XCUIElement *)cellWithAccessibilityId:(NSString *)accessibilityId forIndex:(NSUInteger)index
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSPredicate *identifierPredicate = [NSPredicate predicateWithFormat:@"%K like %@", @"identifier", accessibilityId];
    XCUIElementQuery *cellsQuery = [self.application.cells matchingPredicate:identifierPredicate];
    NSArray *allCells = cellsQuery.allElementsBoundByAccessibilityElement;
    if (index < allCells.count) {
        return allCells[index];
    }
    return nil;
}

- (XCUIElement *)findCollectionViewCellWithAccessibilityId:(NSString *)accessibilityId
                          containsLabelWithAccessibilityId:(NSString *)labelAccessibilityId
                                                 labelText:(NSString *)labelText
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSLog(@"accessibilityId - %@",accessibilityId);
    NSLog(@"labelAccessibilityId - %@", labelAccessibilityId);
    NSLog(@"labelText - %@", labelText);

    XCTAssertNotNil(accessibilityId, @"AccessibilityId shouldn't be 'nil'");

    NSLog(@"All cells in collection view: %@", self.application.cells.allElementsBoundByAccessibilityElement);

    NSPredicate *labelPredicate = [NSPredicate predicateWithBlock:^BOOL(XCUIElement *cell, NSDictionary<NSString *, id> *bindings) {
        NSLog(@"All labels in cell: %@", cell.staticTexts.allElementsBoundByAccessibilityElement);
        XCUIElement *label = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                identifier:labelAccessibilityId
                                             parentElement:cell
                                           filterPredicate:nil
                                                   timeout:kUITestsElementAvailableTimeout];
        if (!label.exists) {
            return NO;
        }
        return [label.label isEqualToString:labelText];
    }];

    XCUIElement *cell = [self waitElementMatchingType:XCUIElementTypeCell
                                           identifier:accessibilityId
                                        parentElement:nil
                                      filterPredicate:labelPredicate
                                              timeout:0];
    return cell;
}

- (XCUIElement *)waitCollectionViewCellWithAccessibilityId:(NSString *)accessibilityId
                          containsLabelWithAccessibilityId:(NSString *)labelAccessibilityId
                                                 labelText:(NSString *)labelText
                                                   timeout:(NSTimeInterval)timeout
{
    XCUIElement *cell = [self findCollectionViewCellWithAccessibilityId:accessibilityId
                                       containsLabelWithAccessibilityId:labelAccessibilityId
                                                              labelText:labelText];
    [self waitElementReady:cell
                   timeout:timeout];
    return cell;
}

- (XCUIElement *)findTableViewCellWithAccessibilityId:(NSString *)accessibilityId
                                containsLabelWithText:(NSString *)labelText
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIApplication *app = self.application;
    XCUIElement *tableView = [app.tables elementBoundByIndex:0]; // TODO: replace with explicit accessibilityId
    NSArray *allCells;

    if (accessibilityId) {
        NSPredicate *identifierPredicate = [NSPredicate predicateWithFormat:@"%K like %@", @"identifier", accessibilityId];
        XCUIElementQuery *cellsQuery = [[tableView childrenMatchingType:XCUIElementTypeCell] matchingPredicate:identifierPredicate];
        allCells = cellsQuery.allElementsBoundByAccessibilityElement;
    } else {
        XCUIElementQuery *cellsQuery = [tableView childrenMatchingType:XCUIElementTypeCell];
        allCells = cellsQuery.allElementsBoundByAccessibilityElement;
    }

    NSPredicate *labelPredicate = [NSPredicate predicateWithBlock:^BOOL(XCUIElement *cell, NSDictionary<NSString *, id> *bindings) {
        XCUIElement *labelElement = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                             text:labelText
                                                    parentElement:cell
                                              shouldBeInHierarchy:YES
                                                          timeout:kUITestsElementAvailableTimeout];
        return labelElement.exists;
    }];

    allCells = [allCells filteredArrayUsingPredicate:labelPredicate];

    NSPredicate *hittablePredicate = [NSPredicate predicateWithFormat:@"%K = true", @"hittable"];
    allCells = [allCells filteredArrayUsingPredicate:hittablePredicate];

    return allCells.firstObject;
}

@end
