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
    NSString *predicateFormat = [NSString stringWithFormat:@"exists == %@", visible ? @1 : @0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
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
    XCUIElement *element;
    if (!parentElement) {
        parentElement = self.application;
    }
    element = [parentElement.otherElements elementMatchingType:XCUIElementTypeOther
                                                    identifier:accessibilityId];
    return element;
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
    XCUIElement *button;
    if (parentElement == nil) {
        button = [self.application.buttons elementMatchingType:XCUIElementTypeButton
                                                    identifier:accessibilityId];
    } else {
        button = [parentElement.buttons elementMatchingType:XCUIElementTypeButton
                                                 identifier:accessibilityId];
    }
    return button;
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
//    sleep(kUITestsElementAvailableTimeout);
    [self waitButtonIsHittable:button];
    return button;
}

- (void)waitButtonIsHittable:(XCUIElement *)button
{
    NSString *predicateFormat = [NSString stringWithFormat:@"hittable == 1"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
    [self expectationForPredicate:predicate
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
- (XCUIElement *)findBackbuttonWithAccessibilityId:(NSString *)accessibilityId
{
    return [self findBackbuttonWithAccessibilityId:accessibilityId
                                 onNavBarWithLabel:nil];
}

- (XCUIElement *)waitBackButtonWithAccessibilityId:(NSString *)accessibilityId
                                           timeout:(NSTimeInterval)timeout
{
    return [self waitBackButtonWithAccessibilityId:accessibilityId
                                 onNavBarWithLabel:nil
                                           timeout:timeout];
}

- (XCUIElement *)findBackbuttonWithAccessibilityId:(NSString *)accessibilityId
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
    XCUIElement *element;
    if (parentElement == nil) {
        element = self.application.textFields[accessibilityId];
    } else {
        element = parentElement.textFields[accessibilityId];
    }
    return element;
}

- (XCUIElement *)findSecureTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                          parentElement:(XCUIElement *)parentElement
{
    XCUIElement *element;
    if (parentElement == nil) {
        element = self.application.secureTextFields[accessibilityId];
    } else {
        element = parentElement.secureTextFields[accessibilityId];
    }
    return element;
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
    NSString *predicateFormat = [NSString stringWithFormat:@"self.identifier == '%@' && (self.hittable == true)", accessibilityId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
    NSArray *allCells = self.application.cells.allElementsBoundByAccessibilityElement;
    NSInteger count = [allCells filteredArrayUsingPredicate:predicate].count;
    return count;
}

- (XCUIElement *)cellWithAccessibilityId:(NSString *)accessibilityId forIndex:(NSUInteger)index
{
    NSString *predicateFormat = [NSString stringWithFormat:@"self.identifier == '%@' && (self.hittable == true)", accessibilityId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
    NSArray *allCells = self.application.cells.allElementsBoundByAccessibilityElement;
    NSArray *filteredCells = [allCells filteredArrayUsingPredicate:predicate];
    if (index < filteredCells.count) {
        return filteredCells[index];
    }
    return nil;
}

- (XCUIElement *)findCellWithAccessibilityId:(NSString *)accessibilityId
            containsLabelWithAccessibilityId:(NSString *)labelAccessibilityId
                                   labelText:(NSString *)labelText
{
    NSArray *allCells = self.application.collectionViews.cells.allElementsBoundByAccessibilityElement;

    NSString *format = [NSString stringWithFormat:@"self.identifier == '%@' && (self.hittable == true)", accessibilityId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
    NSArray *cells = [allCells filteredArrayUsingPredicate:predicate];
    XCUIElement *testCell;
    for (XCUIElement *cell in cells) {
        XCUIElement *label = [self findStaticTextWithAccessibilityId:labelAccessibilityId
                                                       parentElement:cell];        
        if ([label.label isEqualToString:labelText]) {
            testCell = cell;
        }
    }
    return testCell;
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

@end
