//
// Created by Aleksandr Dakhno on 9/1/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Buttons.h"

@implementation JMBaseUITestCase (Helpers)

- (void)waitElementReady:(XCUIElement *)element
                 timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSTimeInterval remain = timeout;
    BOOL elementExist;
    do {
        remain -= kUITestsElementAvailableTimeout;
        sleep(kUITestsElementAvailableTimeout);
        elementExist = element.exists;
        NSLog(@"remain: %@", @(remain));
    } while ( remain >= 0 && !elementExist);

    if (!element.exists) {
        XCTFail(@"Element isn't exist");
    }
}

#pragma mark - Elements with identifiers
- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                              identifier:(NSString *)identifier
                                 timeout:(NSTimeInterval)timeout
{
    return [self waitElementMatchingType:elementType
                              identifier:identifier
                           parentElement:nil
                     shouldBeInHierarchy:YES
                                 timeout:timeout];
}

- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                              identifier:(NSString *)identifier
                           parentElement:(XCUIElement *)parentElement
                                 timeout:(NSTimeInterval)timeout
{
    return [self waitElementMatchingType:elementType
                              identifier:identifier
                           parentElement:parentElement
                     shouldBeInHierarchy:YES
                                 timeout:timeout];
}

- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                              identifier:(NSString *)identifier
                           parentElement:(XCUIElement *)parentElement
                     shouldBeInHierarchy:(BOOL)shouldBeInHierarchy
                                 timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSTimeInterval remain = timeout;
    XCUIElement *element;
    BOOL elementExist;
    do {
        remain -= kUITestsElementAvailableTimeout;
        sleep(kUITestsElementAvailableTimeout);
        element = [self elementMatchingType:elementType
                                 identifier:identifier
                              parentElement:parentElement];
        elementExist = element.exists;
        NSLog(@"remain: %@", @(remain));
        NSLog(@"element.exists: %@ and should be in hierarchy: %@", elementExist ? @"YES" : @"NO", shouldBeInHierarchy ? @"YES" : @"NO");
    } while ( remain >= 0 && elementExist != shouldBeInHierarchy );

    return element;
}

- (XCUIElement *)elementMatchingType:(XCUIElementType)elementType
                          identifier:(NSString *)identifier
                       parentElement:(XCUIElement *)parentElement
{
    if (parentElement == nil) {
        parentElement = self.application;
    }
    XCUIElementQuery *elementsQuery;
    switch (elementType) {
        case XCUIElementTypeOther: {
            elementsQuery = [parentElement.otherElements matchingType:XCUIElementTypeOther
                                                           identifier:identifier];
            break;
        }
        case XCUIElementTypeButton: {
            elementsQuery = [parentElement.buttons matchingType:XCUIElementTypeButton
                                                     identifier:identifier];
            break;
        }
        case XCUIElementTypeStaticText: {
            elementsQuery = [parentElement.staticTexts matchingType:XCUIElementTypeStaticText
                                                         identifier:identifier];
            break;
        }
        case XCUIElementTypeSecureTextField: {
            elementsQuery = [parentElement.secureTextFields matchingType:XCUIElementTypeSecureTextField
                                                              identifier:identifier];
            break;
        }
        case XCUIElementTypeTextField: {
            elementsQuery = [parentElement.textFields matchingType:XCUIElementTypeTextField
                                                        identifier:identifier];
            break;
        }
        case XCUIElementTypeSearchField: {
            elementsQuery = [parentElement.searchFields matchingType:XCUIElementTypeSearchField
                                                          identifier:identifier];
            break;
        }
        default: {
            XCTFail(@"Unknown type");
            break;
        }
    }
    NSArray *allMatchingElements = elementsQuery.allElementsBoundByAccessibilityElement;
    NSLog(@"All matching elements: %@", allMatchingElements);
    if (allMatchingElements.count == 0) {
        return nil;
    } else if (allMatchingElements.count > 1) {
        // TODO: should this be interpreted as an error?
        NSLog(@"Several other elements with id: %@", identifier);
    }
    return allMatchingElements.firstObject;
}


#pragma mark - Elements with text
- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                                    text:(NSString *)text
                                 timeout:(NSTimeInterval)timeout
{
    return [self waitElementMatchingType:elementType
                                    text:text
                           parentElement:nil
                     shouldBeInHierarchy:YES
                                 timeout:timeout];
}

- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                                    text:(NSString *)text
                           parentElement:(XCUIElement *)parentElement
                                 timeout:(NSTimeInterval)timeout
{
    return [self waitElementMatchingType:elementType
                                    text:text
                           parentElement:parentElement
                     shouldBeInHierarchy:YES
                                 timeout:timeout];
}

- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                                    text:(NSString *)text
                           parentElement:(XCUIElement *)parentElement
                     shouldBeInHierarchy:(BOOL)shouldBeInHierarchy
                                 timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSTimeInterval remain = timeout;
    XCUIElement *element;
    BOOL elementExist;
    do {
        remain -= kUITestsElementAvailableTimeout;
        sleep(kUITestsElementAvailableTimeout);
        element = [self elementMatchingType:elementType
                                 text:text
                              parentElement:parentElement];
        elementExist = element.exists;
        NSLog(@"remain: %@", @(remain));
        NSLog(@"element.exists: %@ and should be in hierarchy: %@", elementExist ? @"YES" : @"NO", shouldBeInHierarchy ? @"YES" : @"NO");
    } while ( remain >= 0 && elementExist != shouldBeInHierarchy);

    return element;
}

- (XCUIElement *)elementMatchingType:(XCUIElementType)elementType
                                text:(NSString *)text
                       parentElement:(XCUIElement *)parentElement
{
    if (parentElement == nil) {
        parentElement = self.application;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label CONTAINS %@", text];

    XCUIElementQuery *elementsQuery;
    switch (elementType) {
        case XCUIElementTypeOther: {
            elementsQuery = [parentElement.otherElements matchingPredicate:predicate];
            break;
        }
        case XCUIElementTypeButton: {
            elementsQuery = [parentElement.buttons matchingPredicate:predicate];
            break;
        }
        case XCUIElementTypeStaticText: {
            elementsQuery = [parentElement.staticTexts matchingPredicate:predicate];
            break;
        }
        case XCUIElementTypeSecureTextField: {
            elementsQuery = [parentElement.secureTextFields matchingPredicate:predicate];
            break;
        }
        case XCUIElementTypeTextField: {
            elementsQuery = [parentElement.textFields matchingPredicate:predicate];
            break;
        }
        case XCUIElementTypeSearchField: {
            elementsQuery = [parentElement.searchFields matchingPredicate:predicate];
            break;
        }
        default: {
            XCTFail(@"Unknown type");
            break;
        }
    }
    NSArray *allMatchingElements = elementsQuery.allElementsBoundByAccessibilityElement;
    NSLog(@"All matching elements: %@", allMatchingElements);
    if (allMatchingElements.count == 0) {
        return nil;
    } else if (allMatchingElements.count > 1) {
        // TODO: should this be interpreted as an error?
        NSLog(@"Several other elements with 'text': %@", text);
    }
    return allMatchingElements.firstObject;
}

#pragma mark -  NavigationBars

- (XCUIElement *)findNavigationBarWithLabel:(NSString *)label
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSLog(@"Label: %@", label);
    NSLog(@"All 'other elements':\n%@", [self.application.otherElements allElementsBoundByAccessibilityElement]);
    NSLog(@"All nav bars:\n%@", [self.application.navigationBars allElementsBoundByAccessibilityElement]);
    XCUIApplication *app = self.application;
    XCUIElement *navBar;
    if (label == nil) {
        navBar = [app.navigationBars elementBoundByIndex:0];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(XCUIElement *navBar, NSDictionary<NSString *, id> *bindings) {
            return [navBar.identifier isEqualToString:label];
        }];
        navBar = [app.navigationBars elementMatchingPredicate:predicate];
    }
    return navBar;
}

- (XCUIElement *)waitNavigationBarWithLabel:(NSString *)label
                                    timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSLog(@"Label: %@", label);
    XCUIElement *navBar = [self findNavigationBarWithLabel:label];
    [self waitElementReady:navBar
                   timeout:timeout];
    return navBar;
}

#pragma mark - Cells

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

    XCUIApplication *app = self.application;
    XCUIElement *collectionView = [app.collectionViews elementBoundByIndex:0]; // TODO: replace with explicit accessibilityId
    NSArray *allCells;

    if (accessibilityId) {
        NSPredicate *identifierPredicate = [NSPredicate predicateWithFormat:@"%K like %@", @"identifier", accessibilityId];
        XCUIElementQuery *cellsQuery = [[collectionView childrenMatchingType:XCUIElementTypeCell] matchingPredicate:identifierPredicate];
        allCells = cellsQuery.allElementsBoundByAccessibilityElement;
    } else {
        XCUIElementQuery *cellsQuery = [collectionView childrenMatchingType:XCUIElementTypeCell];
        allCells = cellsQuery.allElementsBoundByAccessibilityElement;
    }

    NSPredicate *labelPredicate = [NSPredicate predicateWithBlock:^BOOL(XCUIElement *cell, NSDictionary<NSString *, id> *bindings) {
        NSLog(@"All labels in cell: %@", cell.staticTexts.allElementsBoundByAccessibilityElement);
        XCUIElement *label = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                identifier:labelAccessibilityId
                                             parentElement:cell
                                       shouldBeInHierarchy:YES
                                                   timeout:0];
        if (!label.exists) {
            return NO;
        }
        return [label.label isEqualToString:labelText];
    }];

    allCells = [allCells filteredArrayUsingPredicate:labelPredicate];

    NSPredicate *hittablePredicate = [NSPredicate predicateWithFormat:@"%K = true", @"hittable"];
    allCells = [allCells filteredArrayUsingPredicate:hittablePredicate];

    return allCells.firstObject;
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
                                                          timeout:0];
        return labelElement.exists;
    }];

    allCells = [allCells filteredArrayUsingPredicate:labelPredicate];

    NSPredicate *hittablePredicate = [NSPredicate predicateWithFormat:@"%K = true", @"hittable"];
    allCells = [allCells filteredArrayUsingPredicate:hittablePredicate];

    return allCells.firstObject;
}

#pragma mark - Search

- (void)searchInMultiSelectedInputControlWithText:(NSString *)searchText
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *searchField = self.application.searchFields[@"Search Values"];
    [self waitElementReady:searchField
                   timeout:kUITestsBaseTimeout];

    [searchField tap];
    [searchField typeText:searchText];
    [self tapButtonWithText:@"Search"
              parentElement:nil
                shouldCheck:YES];
}

#pragma mark - Alerts

- (XCUIElement *)waitAlertInHierarchyWithTitle:(NSString *)title
                                       timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSTimeInterval remain = timeout;
    XCUIElement *alert;
    do {
        remain -= kUITestsElementAvailableTimeout;
        alert = [self findAlertWithTitle:title];;
    } while (alert == nil && remain >= 0);

    return alert;
}

- (XCUIElement *)findAlertWithTitle:(NSString *)title
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    sleep(kUITestsElementAvailableTimeout);
    
    NSLog(@"All alerts : %@", self.application.alerts.allElementsBoundByAccessibilityElement);
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(XCUIElement *evaluatedObject, NSDictionary<NSString *, id> *bindings) {
        BOOL isEqualIdentifiers = [evaluatedObject.identifier isEqualToString:title];
        BOOL isEqualLabel = [evaluatedObject.label isEqualToString:title];
        return isEqualIdentifiers || isEqualLabel;
    }];
    XCUIElementQuery *elementQuery = [self.application.alerts matchingPredicate:predicate];
    NSArray *allElements = elementQuery.allElementsBoundByAccessibilityElement;
    XCUIElement *alert = allElements.firstObject;
    NSLog(@"All found alerts (with title %@): %@", title, allElements);
    return alert;
}

- (XCUIElement *)waitAlertWithTitle:(NSString *)title
                            timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *alert = [self findAlertWithTitle:title];
    if (!alert) {
        alert = [self waitAlertInHierarchyWithTitle:title
                                            timeout:timeout];
    }
    [self waitElementReady:alert
                   timeout:timeout];
    return alert;
}

#pragma mark - Images

- (XCUIElement *)findImageWithAccessibilityId:(NSString *)accessibilityId
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElementQuery *alertsQuery = self.application.images;
    XCUIElement *image = [alertsQuery matchingIdentifier:accessibilityId].element;
    return image;
}

@end
