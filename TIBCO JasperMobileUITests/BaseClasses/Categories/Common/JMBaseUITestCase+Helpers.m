//
// Created by Aleksandr Dakhno on 9/1/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Buttons.h"
#import "XCUIElement+Tappable.h"

@implementation JMBaseUITestCase (Helpers)

- (void)waitElementReady:(XCUIElement *)element
                 timeout:(NSTimeInterval)timeout
{
    if (!element) {
        [self performTestFailedWithErrorMessage:@"Element hasn't passed"
                                     logMessage:NSStringFromSelector(_cmd)];
    }
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSTimeInterval remain = timeout;
    NSInteger waitingInterval = 1;
    BOOL elementExist = element.exists;
    NSLog(@"Element exists: %@", elementExist ? @"YES" : @"NO");
    while ( remain > 0 && !elementExist) {
        remain -= waitingInterval;
        sleep(waitingInterval);

        elementExist = element.exists;
        NSLog(@"remain: %@", @(remain));
        NSLog(@"Element exists: %@", elementExist ? @"YES" : @"NO");
    }

    if (!element.exists) {
        [self performTestFailedWithErrorMessage:@"Element wasn't found"
                                     logMessage:NSStringFromSelector(_cmd)];
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
                         filterPredicate:nil
                     shouldBeInHierarchy:YES
                                 timeout:timeout];
}

- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                              identifier:(NSString *)identifier
                           parentElement:(XCUIElement *)parentElement
                         filterPredicate:(NSPredicate *)filterPredicate
                                 timeout:(NSTimeInterval)timeout
{
    return [self waitElementMatchingType:elementType
                              identifier:identifier
                           parentElement:parentElement
                         filterPredicate:filterPredicate
                     shouldBeInHierarchy:YES
                                 timeout:timeout];
}

- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                              identifier:(NSString *)identifier
                           parentElement:(XCUIElement *)parentElement
                         filterPredicate:(NSPredicate *)filterPredicate
                     shouldBeInHierarchy:(BOOL)shouldBeInHierarchy
                                 timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSTimeInterval remain = timeout;
    NSInteger waitingInterval = 1;
    XCUIElement *element = [self elementMatchingType:elementType
                                          identifier:identifier
                                       parentElement:parentElement
                                     filterPredicate:filterPredicate];
    BOOL elementExist = element.exists;
    BOOL condition = (remain > 0) && (shouldBeInHierarchy == !elementExist);
    NSLog(@"element.exists: %@ and should exist: %@", elementExist ? @"YES" : @"NO", shouldBeInHierarchy ? @"YES" : @"NO");
    NSLog(@"condition: %@", condition ? @"true" : @"false");
    NSLog(@"remain: %@", @(remain));
    while ( condition ) {
        remain -= waitingInterval;
        sleep(waitingInterval);
        element = [self elementMatchingType:elementType
                                 identifier:identifier
                              parentElement:parentElement
                            filterPredicate:filterPredicate];
        elementExist = element.exists;
        condition = (remain > 0) && (shouldBeInHierarchy == !elementExist);
        NSLog(@"element.exists: %@ and should be in hierarchy: %@", elementExist ? @"YES" : @"NO", shouldBeInHierarchy ? @"YES" : @"NO");
        NSLog(@"condition: %@", condition ? @"true" : @"false");
        NSLog(@"remain: %@", @(remain));
    }

    return element;
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
                     shouldBeInHierarchy:(BOOL)shouldExist
                                 timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSTimeInterval remain = timeout;
    NSInteger waitingInterval = 1;
    XCUIElement *element = [self elementMatchingType:elementType
                                                text:text
                                       parentElement:parentElement];
    BOOL elementExist = element.exists;
    BOOL condition = (remain > 0) && (shouldExist == !elementExist);
    NSLog(@"element.exists: %@ and should be in hierarchy: %@", elementExist ? @"YES" : @"NO", shouldExist ? @"YES" : @"NO");
    NSLog(@"condition: %@", condition ? @"true" : @"false");
    NSLog(@"remain: %@", @(remain));
    while ( condition ) {
        remain -= waitingInterval;
        sleep(waitingInterval);
        element = [self elementMatchingType:elementType
                                       text:text
                              parentElement:parentElement];
        elementExist = element.exists;
        condition = (remain > 0) && (shouldExist == !elementExist);
        NSLog(@"element.exists: %@ and should be in hierarchy: %@", elementExist ? @"YES" : @"NO", shouldExist ? @"YES" : @"NO");
        NSLog(@"condition: %@", condition ? @"true" : @"false");
        NSLog(@"remain: %@", @(remain));
    }

    return element;
}

#pragma mark - Elements with predicate

- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                           parentElement:(XCUIElement *)parentElement
                         filterPredicate:(NSPredicate *)filterPredicate
                                 timeout:(NSTimeInterval)timeout
{
    return [self waitElementMatchingType:elementType
                           parentElement:parentElement
                         filterPredicate:filterPredicate
                     shouldBeInHierarchy:YES
                                 timeout:timeout];
}

- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                           parentElement:(XCUIElement *)parentElement
                         filterPredicate:(NSPredicate *)filterPredicate
                     shouldBeInHierarchy:(BOOL)shouldExist
                                 timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSTimeInterval remain = timeout;
    NSInteger waitingInterval = 1;
    XCUIElement *element = [self elementMatchingType:elementType
                                       parentElement:parentElement
                                     filterPredicate:filterPredicate];
    BOOL elementExist = element.exists;
    BOOL condition = (remain > 0) && (shouldExist == !elementExist);
    NSLog(@"element.exists: %@ and should be in hierarchy: %@", elementExist ? @"YES" : @"NO", shouldExist ? @"YES" : @"NO");
    NSLog(@"condition: %@", condition ? @"true" : @"false");
    NSLog(@"remain: %@", @(remain));
    while ( condition ) {
        remain -= waitingInterval;
        sleep(waitingInterval);
        element = [self elementMatchingType:elementType
                              parentElement:parentElement
                            filterPredicate:filterPredicate];
        elementExist = element.exists;
        condition = (remain > 0) && (shouldExist == !elementExist);
        NSLog(@"element.exists: %@ and should be in hierarchy: %@", elementExist ? @"YES" : @"NO", shouldExist ? @"YES" : @"NO");
        NSLog(@"condition: %@", condition ? @"true" : @"false");
        NSLog(@"remain: %@", @(remain));
    }

    return element;
}

- (XCUIElement *)elementMatchingType:(XCUIElementType)elementType
                       parentElement:(XCUIElement *)parentElement
                     filterPredicate:(NSPredicate *)filterPredicate
{
    return [[self elementQueryMatchingType:elementType
                                identifier:nil
                                      text:nil
                             parentElement:parentElement].allElementsBoundByAccessibilityElement filteredArrayUsingPredicate:filterPredicate].firstObject;
}

#pragma mark - Elements by index
- (XCUIElement *)elementMatchingType:(XCUIElementType)elementType
                          identifier:(NSString *)identifier
                       parentElement:(XCUIElement *)parentElement
                             atIndex:(NSUInteger)index
{
    return [[self elementQueryMatchingType:elementType
                                identifier:identifier
                                      text:nil
                             parentElement:parentElement] elementBoundByIndex:index];
}

- (XCUIElement *)elementMatchingType:(XCUIElementType)elementType
                                text:(NSString *)text
                       parentElement:(XCUIElement *)parentElement
                             atIndex:(NSUInteger)index
{
    return [[self elementQueryMatchingType:elementType
                                identifier:nil
                                     text:text
                            parentElement:parentElement] elementBoundByIndex:index];
}

- (XCUIElement *)elementMatchingType:(XCUIElementType)elementType
                       parentElement:(XCUIElement *)parentElement
                             atIndex:(NSUInteger)index
{
    return [[self elementQueryMatchingType:elementType
                                identifier:nil
                                      text:nil
                             parentElement:parentElement] elementBoundByIndex:index];
}

#pragma mark -  NavigationBars

- (XCUIElement *)findNavigationBarWithLabel:(NSString *)label
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSLog(@"Label: %@", label);
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

#pragma mark - Search

- (void)searchInMultiSelectedInputControlWithText:(NSString *)searchText
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *searchField = self.application.searchFields[@"Search Values"];
    [self waitElementReady:searchField
                   timeout:kUITestsBaseTimeout];

    [searchField tapByWaitingHittable];
    [searchField typeText:searchText];
    [self tapButtonWithText:@"Search"
              parentElement:nil
                shouldCheck:YES];
}

#pragma mark - Images

- (XCUIElement *)findImageWithAccessibilityId:(NSString *)accessibilityId
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElementQuery *alertsQuery = self.application.images;
    XCUIElement *image = [alertsQuery matchingIdentifier:accessibilityId].element;
    return image;
}

#pragma mark - Utils

- (XCUIElement *)elementMatchingType:(XCUIElementType)elementType
                          identifier:(NSString *)identifier
                       parentElement:(XCUIElement *)parentElement
{
    return [self elementMatchingType:elementType
                          identifier:identifier
                       parentElement:parentElement
                     filterPredicate:nil];
}

- (XCUIElement *)elementMatchingType:(XCUIElementType)elementType
                          identifier:(NSString *)identifier
                       parentElement:(XCUIElement *)parentElement
                     filterPredicate:(NSPredicate *)filterPredicate
{
    XCUIElementQuery *query = [self elementQueryMatchingType:elementType
                                                  identifier:identifier
                                                        text:nil
                                               parentElement:parentElement];

    NSArray *allMatchingElements = query.allElementsBoundByAccessibilityElement;
    if (allMatchingElements.count == 0) {
        return nil;
    } else if (filterPredicate) {
        allMatchingElements = [allMatchingElements filteredArrayUsingPredicate:filterPredicate];
    }

    if (allMatchingElements.count > 1) {
        // TODO: should this be interpreted as an error?
        NSLog(@"Several other elements: %@", allMatchingElements);
    }

    return allMatchingElements.firstObject;
}

- (XCUIElement *)elementMatchingType:(XCUIElementType)elementType
                                text:(NSString *)text
                       parentElement:(XCUIElement *)parentElement
{
    XCUIElementQuery *query = [self elementQueryMatchingType:elementType
                                                  identifier:nil
                                                        text:text
                                               parentElement:parentElement];
    return [query elementBoundByIndex:0];
}

- (XCUIElementQuery *)elementQueryMatchingType:(XCUIElementType)elementType
                                    identifier:(NSString *)identifier
                                          text:(NSString *)text
                                 parentElement:(XCUIElement *)parentElement
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (parentElement == nil) {
        parentElement = self.application;
    }

    NSPredicate *predicate;
    if (text) {
        predicate = [NSPredicate predicateWithBlock:^BOOL(XCUIElement *element, NSDictionary<NSString *, id> *bindings) {
            NSLog(@"Text for matching: %@", text);
            NSLog(@"element: %@", element);
//            NSLog(@"[element.identifier isEqualToString:text]: %@", [element.identifier isEqualToString:text] ? @"YES": @"NO");
//            NSLog(@"[element.label isEqualToString:text]: %@", [element.label isEqualToString:text] ? @"YES": @"NO");
//            NSLog(@"[element.label containsString:text]: %@", [element.label containsString:text] ? @"YES": @"NO");
            return [element.identifier isEqualToString:text] || [element.label isEqualToString:text] || [element.label containsString:text];
        }];
    }

    XCUIElementQuery *elementsQuery;
    switch (elementType) {
        case XCUIElementTypeOther: {
            if (predicate) {
                elementsQuery = [parentElement.otherElements matchingPredicate:predicate];
            } else if (identifier) {
                elementsQuery = [parentElement.otherElements matchingType:XCUIElementTypeOther
                                                               identifier:identifier];
            } else {
                elementsQuery = parentElement.otherElements;
            }
            break;
        }
        case XCUIElementTypeButton: {
            if (predicate) {
                elementsQuery = [parentElement.buttons matchingPredicate:predicate];
            } else if(identifier) {
                elementsQuery = [parentElement.buttons matchingType:XCUIElementTypeButton
                                                         identifier:identifier];
            } else {
                elementsQuery = parentElement.buttons;
            }
            break;
        }
        case XCUIElementTypeStaticText: {
            if (predicate) {
                elementsQuery = [parentElement.staticTexts matchingPredicate:predicate];
            } else if (identifier) {
                elementsQuery = [parentElement.staticTexts matchingType:XCUIElementTypeStaticText
                                                             identifier:identifier];
            } else {
                elementsQuery = parentElement.staticTexts;
            }
            break;
        }
        case XCUIElementTypeSecureTextField: {
            if (predicate) {
                elementsQuery = [parentElement.secureTextFields matchingPredicate:predicate];
            } else if (identifier) {
                elementsQuery = [parentElement.secureTextFields matchingType:XCUIElementTypeSecureTextField
                                                                  identifier:identifier];
            } else {
                elementsQuery = parentElement.secureTextFields;
            }
            break;
        }
        case XCUIElementTypeTextField: {
            if (predicate) {
                elementsQuery = [parentElement.textFields matchingPredicate:predicate];
            } else if (identifier) {
                elementsQuery = [parentElement.textFields matchingType:XCUIElementTypeTextField
                                                            identifier:identifier];
            } else {
                elementsQuery = parentElement.textFields;
            }
            break;
        }
        case XCUIElementTypeSearchField: {
            if (predicate) {
                elementsQuery = [parentElement.searchFields matchingPredicate:predicate];
            } else if (identifier) {
                elementsQuery = [parentElement.searchFields matchingType:XCUIElementTypeSearchField
                                                              identifier:identifier];
            } else {
                elementsQuery = parentElement.searchFields;
            }
            break;
        }
        case XCUIElementTypeCell: {
            if (predicate) {
                elementsQuery = [parentElement.cells matchingPredicate:predicate];
            } else if (identifier) {
                elementsQuery = [parentElement.cells matchingType:XCUIElementTypeCell
                                                       identifier:identifier];
            } else {
                elementsQuery = parentElement.cells;
            }
            break;
        }
        case XCUIElementTypeCollectionView: {
            if (predicate) {
                elementsQuery = [parentElement.collectionViews matchingPredicate:predicate];
            } else if (identifier) {
                elementsQuery = [parentElement.collectionViews matchingType:XCUIElementTypeCollectionView
                                                                 identifier:identifier];
            } else {
                elementsQuery = parentElement.collectionViews;
            }
            break;
        }
        case XCUIElementTypeTable: {
            if (predicate) {
                elementsQuery = [parentElement.tables matchingPredicate:predicate];
            } else if (identifier) {
                elementsQuery = [parentElement.tables matchingType:XCUIElementTypeTable
                                                        identifier:identifier];
            } else {
                elementsQuery = parentElement.tables;
            }
            break;
        }
        default: {
            [self performTestFailedWithErrorMessage:[NSString stringWithFormat:@"Unknown type was supplied: %@", @(elementType)]
                                         logMessage:NSStringFromSelector(_cmd)];
            break;
        }
    }
    return elementsQuery;
}

@end
