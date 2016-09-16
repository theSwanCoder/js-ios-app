//
// Created by Aleksandr Dakhno on 9/1/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Helpers.h"

@implementation JMBaseUITestCase (Helpers)

- (void)waitElement:(XCUIElement *)element
            timeout:(NSTimeInterval)timeout
{
    [self waitElement:element
            visible:true
              timeout:timeout];
}

- (void)waitElement:(XCUIElement *)element
            visible:(BOOL)visible
            timeout:(NSTimeInterval)timeout
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", @"exists", visible ? @1 : @0];
    [self expectationForPredicate:predicate
              evaluatedWithObject:element
                          handler:^BOOL {
                              NSLog(@"\nElement %@ was fulfilled", element);
                              return YES;
                          }];

    [self waitForExpectationsWithTimeout:timeout
                                 handler:^(NSError *error) {
                                     NSLog(@"\nElement: %@, \nError of waiting: %@", element, error);
                                     if (error) {
                                         XCTFail(@"Error of waiting: %@", error);
                                     }
                                 }];
}

- (XCUIElement *)findNavigationBarWithLabel:(NSString *)label
{
    XCUIApplication *app = self.application;
    XCUIElement *navBar;
    if (label == nil) {
        navBar = [app.navigationBars elementBoundByIndex:0];
    } else {
        navBar = [app.navigationBars elementMatchingType:XCUIElementTypeNavigationBar
                                              identifier:label];
    }
    return navBar;
}

- (XCUIElement *)waitNavigationBarWithLabel:(NSString *)label
                                    timeout:(NSTimeInterval)timeout
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:label];
    [self waitElement:navBar
              timeout:timeout];
    return navBar;
}

#pragma mark - General Elements
- (XCUIElement *)elementWithAccessibilityId:(NSString *)accessibilityId
                              parentElement:(XCUIElement *)parentElement
{
    if (!parentElement) {
        parentElement = self.application;
    }
    XCUIElementQuery *elementsQuery = [parentElement.otherElements matchingType:XCUIElementTypeOther
                                                                     identifier:accessibilityId];
    NSArray *allMatchingElements = elementsQuery.allElementsBoundByAccessibilityElement;
    if (allMatchingElements.count == 0) {
        return nil;
    } else if (allMatchingElements.count > 1) {
        // TODO: should this be interpreted as an error?
        NSLog(@"Several other elements with id: %@", accessibilityId);
    }
    return allMatchingElements.firstObject;
}

- (XCUIElement *)findElementWithAccessibilityId:(NSString *)accessibilityId
{
    return [self findElementWithAccessibilityId:accessibilityId
                                  parentElement:nil];
}

- (XCUIElement *)waitElementWithAccessibilityId:(NSString *)accessibilityId
                                        timeout:(NSTimeInterval)timeout
{
    return [self waitElementWithAccessibilityId:accessibilityId
                                  parentElement:nil
                                        timeout:timeout];
}

- (XCUIElement *)findElementWithAccessibilityId:(NSString *)accessibilityId
                                  parentElement:(XCUIElement *)parentElement
{
    XCUIElement *element = [self elementWithAccessibilityId:accessibilityId
                                              parentElement:parentElement];
    if (!element.exists) {
        return nil;
    }
    return element;
}

- (XCUIElement *)waitElementWithAccessibilityId:(NSString *)accessibilityId
                                  parentElement:(XCUIElement *)parentElement
                                        timeout:(NSTimeInterval)timeout
{
    return [self waitElementWithAccessibilityId:accessibilityId
                                  parentElement:parentElement
                                        visible:true
                                        timeout:timeout];
}

- (XCUIElement *)waitElementWithAccessibilityId:(NSString *)accessibilityId
                                  parentElement:(XCUIElement *)parentElement
                                        visible:(BOOL)visible
                                        timeout:(NSTimeInterval)timeout
{
    XCUIElement *element = [self elementWithAccessibilityId:accessibilityId
                                              parentElement:parentElement];
    if (!element) {
        return nil;
    }
    [self waitElement:element
              visible:visible
              timeout:timeout];
    return element;
}

#pragma mark - General Buttons

- (XCUIElement *)findButtonWithAccessibilityId:(NSString *)accessibilityId
{
    return [self findButtonWithAccessibilityId:accessibilityId
                                 parentElement:nil];
}

- (XCUIElement *)waitButtonWithAccessibilityId:(NSString *)accessibilityId
                                       timeout:(NSTimeInterval)timeout
{
    return [self waitButtonWithAccessibilityId:accessibilityId
                                 parentElement:nil
                                       timeout:timeout];
}

- (XCUIElement *)buttonWithAccessibilityId:(NSString *)accessibilityId
                             parentElement:(XCUIElement *)parentElement
{
    if (parentElement == nil) {
        parentElement = self.application;
    }
    XCUIElementQuery *buttonsQuery = [parentElement.buttons matchingType:XCUIElementTypeButton 
                                                              identifier:accessibilityId];
    NSArray *allMatchingButtons = buttonsQuery.allElementsBoundByAccessibilityElement;
    if (allMatchingButtons.count == 0) {
        return nil;
    } else if (allMatchingButtons.count > 1) {
        // TODO: should this be interpreted as an error?
        NSLog(@"Several button with id: %@", accessibilityId);
    }
    return allMatchingButtons.firstObject;
}

- (XCUIElement *)findButtonWithAccessibilityId:(NSString *)accessibilityId
                                 parentElement:(XCUIElement *)parentElement
{
    XCUIElement *button = [self buttonWithAccessibilityId:accessibilityId
                                            parentElement:parentElement];
    if (!button.exists || !button.isHittable) {
        return nil;
    }
    return button;
}

- (XCUIElement *)waitButtonWithAccessibilityId:(NSString *)accessibilityId
                                 parentElement:(XCUIElement *)parentElement
                                       timeout:(NSTimeInterval)timeout
{
    XCUIElement *button = [self buttonWithAccessibilityId:accessibilityId
                                            parentElement:parentElement];
    [self waitElement:button
              timeout:timeout];
    [self waitButtonIsHittable:button];
    return button;
}

- (void)waitButtonIsHittable:(XCUIElement *)button
{
    NSPredicate *hittablePredicate = [NSPredicate predicateWithFormat:@"%K = true", @"hittable"];
    [self expectationForPredicate:hittablePredicate
              evaluatedWithObject:button
                          handler:^BOOL {
                              NSLog(@"\nElement %@ was fulfilled", button);
                              return YES;
                          }];
    [self waitForExpectationsWithTimeout:kUITestsBaseTimeout
                                 handler:^(NSError *error) {
                                     NSLog(@"\nElement: %@, \nError of waiting: %@", button, error);
                                     if (error) {
                                         XCTFail(@"Error of waiting: %@", error);
                                     }
                                 }];
}

#pragma mark - Back buttons
- (XCUIElement *)findBackButtonWithAccessibilityId:(NSString *)accessibilityId
{
    return [self findBackButtonWithAccessibilityId:accessibilityId
                                 onNavBarWithLabel:nil];
}

- (XCUIElement *)waitBackButtonWithAccessibilityId:(NSString *)accessibilityId
                                           timeout:(NSTimeInterval)timeout
{
    return [self waitBackButtonWithAccessibilityId:accessibilityId
                                 onNavBarWithLabel:nil
                                           timeout:timeout];
}

- (XCUIElement *)findBackButtonWithAccessibilityId:(NSString *)accessibilityId
                                 onNavBarWithLabel:(NSString *)label
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:label
                                                   timeout:kUITestsBaseTimeout];
    XCUIElement *button = [self findButtonWithAccessibilityId:accessibilityId
                                                parentElement:navBar];
    return button;
}

- (XCUIElement *)waitBackButtonWithAccessibilityId:(NSString *)accessibilityId
                                 onNavBarWithLabel:(NSString *)label
                                           timeout:(NSTimeInterval)timeout
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:label
                                                   timeout:timeout];
    XCUIElement *button = [self waitButtonWithAccessibilityId:accessibilityId
                                                parentElement:navBar
                                                      timeout:timeout];
    return button;
}

#pragma mark - Text Fields

- (XCUIElement *)findTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                    parentElement:(XCUIElement *)parentElement
{   
    if (parentElement == nil) {
        parentElement = self.application;
    }
    XCUIElementQuery *textFieldsQuery = [parentElement.textFields matchingType:XCUIElementTypeTextField 
                                                                    identifier:accessibilityId];
    NSArray *allMatchingTextFields = textFieldsQuery.allElementsBoundByAccessibilityElement;
    if (allMatchingTextFields.count == 0) {
        return nil;
    } else if (allMatchingTextFields.count > 1) {
        // TODO: should this be interpreted as an error?
        NSLog(@"Several text fields with id: %@", accessibilityId);
    }
    return allMatchingTextFields.firstObject;
}

- (XCUIElement *)findSecureTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                          parentElement:(XCUIElement *)parentElement
{
    if (parentElement == nil) {
        parentElement = self.application;
    }
    XCUIElementQuery *textFieldsQuery = [parentElement.secureTextFields matchingType:XCUIElementTypeSecureTextField 
                                                         identifier:accessibilityId];
    NSArray *allMatchingTextFields = textFieldsQuery.allElementsBoundByAccessibilityElement;
    if (allMatchingTextFields.count == 0) {
        return nil;
    } else if (allMatchingTextFields.count > 1) {
        // TODO: should this be interpreted as an error?
        NSLog(@"Several text fields with id: %@", accessibilityId);
    }
    return allMatchingTextFields.firstObject;
}

- (XCUIElement *)waitTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                          timeout:(NSTimeInterval)timeout
{
    return [self waitTextFieldWithAccessibilityId:accessibilityId
                                    parentElement:nil
                                          timeout:timeout];
}

- (XCUIElement *)waitTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                    parentElement:(XCUIElement *)parentElement
                                          timeout:(NSTimeInterval)timeout
{
    XCUIElement *textField = [self findTextFieldWithAccessibilityId:accessibilityId
                                                      parentElement:parentElement];
    [self waitElement:textField
              timeout:timeout];
    return textField;
}

- (XCUIElement *)waitSecureTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                                timeout:(NSTimeInterval)timeout
{
    return [self waitSecureTextFieldWithAccessibilityId:accessibilityId
                                          parentElement:nil
                                                timeout:timeout];
}

- (XCUIElement *)waitSecureTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                          parentElement:(XCUIElement *)parentElement
                                                timeout:(NSTimeInterval)timeout
{
    XCUIElement *textField = [self findSecureTextFieldWithAccessibilityId:accessibilityId
                                                            parentElement:parentElement];
    [self waitElement:textField
              timeout:timeout];
    return textField;
}

#pragma mark - Static Text

- (XCUIElement *)findStaticTextWithAccessibilityId:(NSString *)accessibilityId
{
    return [self findStaticTextWithAccessibilityId:accessibilityId
                                     parentElement:nil];
}

- (XCUIElement *)waitStaticTextWithAccessibilityId:(NSString *)accessibilityId
                                           timeout:(NSTimeInterval)timeout
{
    return [self waitStaticTextWithAccessibilityId:accessibilityId
                                     parentElement:nil
                                           timeout:timeout];
}

- (XCUIElement *)findStaticTextWithAccessibilityId:(NSString *)accessibilityId
                                     parentElement:(XCUIElement *)parentElement
{
    if (parentElement == nil) {
        parentElement = self.application;
    }
    XCUIElement *element = parentElement.staticTexts[accessibilityId];
    return element;
}

- (XCUIElement *)waitStaticTextWithAccessibilityId:(NSString *)accessibilityId
                                     parentElement:(XCUIElement *)parentElement
                                           timeout:(NSTimeInterval)timeout
{
    XCUIElement *element = [self findStaticTextWithAccessibilityId:accessibilityId
                                                     parentElement:parentElement];
    [self waitElement:element
              timeout:timeout];
    return element;
}

- (XCUIElement *)waitStaticTextWithAccessibilityId:(NSString *)accessibilityId
                                     parentElement:(XCUIElement *)parentElement
                                           visible:(BOOL)visible
                                           timeout:(NSTimeInterval)timeout
{
    XCUIElement *element = [self findStaticTextWithAccessibilityId:accessibilityId
                                                     parentElement:parentElement];
    [self waitElement:element
              visible:visible
              timeout:timeout];
    return element;
}

#pragma mark - Actions View

- (XCUIElement *)findActionsButton
{
    return [self findActionsButtonOnNavBarWithLabel:nil];
}

- (XCUIElement *)findActionsButtonOnNavBarWithLabel:(NSString *)label
{
    XCUIElement *navBar;
    if (label) {
        navBar = [self waitNavigationBarWithLabel:label
                                          timeout:kUITestsBaseTimeout];
    }
    XCUIElement *actionsButton = [self findButtonWithAccessibilityId:@"Share"
                                                       parentElement:navBar];
    return actionsButton;
}

- (XCUIElement *)waitActionsButtonWithTimeout:(NSTimeInterval)timeout
{
    return [self waitActionsButtonOnNavBarWithLabel:nil
                                            timeout:timeout];
}

- (XCUIElement *)waitActionsButtonOnNavBarWithLabel:(NSString *)label
                                            timeout:(NSTimeInterval)timeout
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:label
                                                   timeout:timeout];
    XCUIElement *actionsButton = [self waitButtonWithAccessibilityId:@"Share"
                                                       parentElement:navBar
                                                             timeout:timeout];
    return actionsButton;
}

#pragma mark - Other buttons

- (XCUIElement *)waitMenuButtonWithTimeout:(NSTimeInterval)timeout
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:nil
                                                   timeout:timeout];
    XCUIElement *menuButton = [self waitButtonWithAccessibilityId:@"menu icon"
                                                    parentElement:navBar
                                                          timeout:timeout];
    return menuButton;
}

- (XCUIElement *)waitDoneButtonWithTimeout:(NSTimeInterval)timeout
{
    return [self waitButtonWithAccessibilityId:@"Done"
                                       timeout:timeout];
}

#pragma mark - Cells

- (NSInteger)countCellsWithAccessibilityId:(NSString *)accessibilityId
{
    NSPredicate *identifierPredicate = [NSPredicate predicateWithFormat:@"%K like %@", @"identifier", accessibilityId];
    NSPredicate *hittablePredicate = [NSPredicate predicateWithFormat:@"%K = true", @"hittable"];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[identifierPredicate, hittablePredicate]];
    XCUIElementQuery *cellsQuery = [[self.application childrenMatchingType:XCUIElementTypeCell] matchingPredicate:predicate];
    NSArray *allCells = cellsQuery.allElementsBoundByAccessibilityElement;

    return allCells.count;
}

- (XCUIElement *)cellWithAccessibilityId:(NSString *)accessibilityId forIndex:(NSUInteger)index
{
    NSPredicate *identifierPredicate = [NSPredicate predicateWithFormat:@"%K like %@", @"identifier", accessibilityId];
    NSPredicate *hittablePredicate = [NSPredicate predicateWithFormat:@"%K = true", @"hittable"];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[identifierPredicate, hittablePredicate]];
    XCUIElementQuery *cellsQuery = [[self.application childrenMatchingType:XCUIElementTypeCell] matchingPredicate:predicate];
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
        XCUIElement *label = [self findStaticTextWithAccessibilityId:labelAccessibilityId
                                                       parentElement:cell];
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
        XCUIElement *labelElement = [self findStaticTextWithAccessibilityId:labelText
                                                       parentElement:cell];
        return labelElement.exists;
    }];

    allCells = [allCells filteredArrayUsingPredicate:labelPredicate];

    NSPredicate *hittablePredicate = [NSPredicate predicateWithFormat:@"%K = true", @"hittable"];
    allCells = [allCells filteredArrayUsingPredicate:hittablePredicate];

    return allCells.firstObject;
}

#pragma mark - Search
- (void)searchResourceWithName:(NSString *)resourceName inSection:(NSString *)sectionName
{
    // TODO: add support of sections. for now we consider that active 'library' section
    XCUIElement *searchResourcesSearchField = self.application.searchFields[@"Search resources"];
    [self waitElement:searchResourcesSearchField
              timeout:kUITestsBaseTimeout];

    [searchResourcesSearchField tap];
    [searchResourcesSearchField typeText:resourceName];

    XCUIElement *searchButton = [self waitButtonWithAccessibilityId:@"Search"
                                                            timeout:kUITestsBaseTimeout];
    [searchButton tap];
}

- (void)searchInMultiSelectedInputControlWithText:(NSString *)searchText
{
    XCUIElement *searchField = self.application.searchFields[@"Search Values"];
    [self waitElement:searchField
              timeout:kUITestsBaseTimeout];

    [searchField tap];
    [searchField typeText:searchText];

    XCUIElement *searchButton = [self waitButtonWithAccessibilityId:@"Search"
                                                            timeout:kUITestsBaseTimeout];
    [searchButton tap];
}

@end
