//
// Created by Aleksandr Dakhno on 9/1/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Helpers.h"

@implementation JMBaseUITestCase (Helpers)

- (void)waitElement:(XCUIElement *)element
            visible:(BOOL)visible
            timeout:(NSTimeInterval)timeout
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.exists == %@", visible ? @1 : @0];
    [self expectationForPredicate:predicate
              evaluatedWithObject:element
                          handler:nil];

    [self waitForExpectationsWithTimeout:timeout
                                 handler:^(NSError *error) {
                                     NSLog(@"\nElement: %@, \nError of waiting: %@", element, error);
                                 }];
}

- (XCUIElement *)waitNavigationBarWithLabel:(NSString *)label
                                    timeout:(NSTimeInterval)timeout
{
    XCUIApplication *app = self.application;
    XCUIElement *navBar;
    if (label == nil) {
        navBar = [app.navigationBars elementBoundByIndex:0];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", label];
        navBar = [app.navigationBars elementMatchingPredicate:predicate];
    }
    [self waitElement:navBar
              visible:true
              timeout:timeout];
    return navBar;
}

#pragma mark - General Elements

- (XCUIElement *)findElementWithAccessibilityId:(NSString *)accessibilityId
{
    return [self findElementWithAccessibilityId:accessibilityId
                                  parentElement:nil];
}

- (XCUIElement *)findElementWithAccessibilityId:(NSString *)accessibilityId
                                  parentElement:(XCUIElement *)parentElement
{
    XCUIElement *element;
    if (parentElement == nil) {
        element = self.application.otherElements[accessibilityId];
    } else {
        element = parentElement.otherElements[accessibilityId];
    }
    if (!element.exists) {
        return nil;
    }
    return element;
}

- (XCUIElement *)waitElementWithAccessibilityId:(NSString *)accessibilityId
                                        timeout:(NSTimeInterval)timeout
{
    return [self waitElementWithAccessibilityId:accessibilityId
                                        visible:true
                                        timeout:timeout];
}

- (XCUIElement *)waitElementWithAccessibilityId:(NSString *)accessibilityId
                                        visible:(BOOL)visible
                                        timeout:(NSTimeInterval)timeout
{
    return [self waitElementWithAccessibilityId:accessibilityId
                                  parentElement:nil
                                        visible:visible
                                        timeout:timeout];
}

- (XCUIElement *)waitElementWithAccessibilityId:(NSString *)accessibilityId
                                  parentElement:(XCUIElement *)parentElement
                                        visible:(BOOL)visible
                                        timeout:(NSTimeInterval)timeout
{
    XCUIElement *element = [self findElementWithAccessibilityId:accessibilityId
                                                  parentElement:parentElement];
    if (!element) {
        XCTFail(@"Element doesn't exist with accessibility id: %@", accessibilityId);
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

- (XCUIElement *)findButtonWithAccessibilityId:(NSString *)accessibilityId
                                 parentElement:(XCUIElement *)parentElement
{
    // HACK - We need add sleep here, because sometimes the button isn't available right away.
    sleep(kUITestsElementAvailableTimeout);
    XCUIElement *button;
    if (parentElement == nil) {
        button = self.application.buttons[accessibilityId];
    } else {
        button = parentElement.buttons[accessibilityId];
    }
    if (!button.exists) {
        return nil;
    }
    return button;
}

- (XCUIElement *)waitButtonWithAccessibilityId:(NSString *)accessibilityId
                                       timeout:(NSTimeInterval)timeout
{
    return [self waitButtonWithAccessibilityId:accessibilityId
                                       visible:true
                                       timeout:timeout];
}

- (XCUIElement *)waitButtonWithAccessibilityId:(NSString *)accessibilityId
                                       visible:(BOOL)visible
                                       timeout:(NSTimeInterval)timeout
{
    return [self waitButtonWithAccessibilityId:accessibilityId
                                 parentElement:nil
                                       visible:visible
                                       timeout:timeout];
}

- (XCUIElement *)waitButtonWithAccessibilityId:(NSString *)accessibilityId
                                 parentElement:(XCUIElement *)parentElement
                                       visible:(BOOL)visible
                                       timeout:(NSTimeInterval)timeout
{
    XCUIElement *button = [self findButtonWithAccessibilityId:accessibilityId
                                                parentElement:parentElement];
    if (!button) {
        XCTFail(@"Button doesn't exist with accessibility id: %@", accessibilityId);
    }
    [self waitElement:button
              visible:visible
              timeout:timeout];
    if (!button.isHittable) {
        XCTFail(@"Button doesn't exist with accessibility id: %@", accessibilityId);
    }
    // HACK - We need add sleep here, because sometimes the button isn't 'tappable', right after getting it
    sleep(kUITestsElementAvailableTimeout);
    return button;
}

#pragma mark - Back buttons

- (XCUIElement *)waitBackButtonWithAccessibilityId:(NSString *)accessibilityId
                                           timeout:(NSTimeInterval)timeout
{
    return [self waitBackButtonWithAccessibilityId:accessibilityId
                                 onNavBarWithLabel:nil
                                           timeout:timeout];
}

- (XCUIElement *)waitBackButtonWithAccessibilityId:(NSString *)accessibilityId
                                 onNavBarWithLabel:(NSString *)label
                                           timeout:(NSTimeInterval)timeout
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:label
                                                   timeout:timeout];
    XCUIElement *button = [self waitButtonWithAccessibilityId:accessibilityId
                                                parentElement:navBar
                                                      visible:true
                                                      timeout:timeout];
    // HACK - We need add sleep here, because sometimes the button isn't 'tappable', right after getting it
    sleep(kUITestsElementAvailableTimeout);
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
              visible:true
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
              visible:true
              timeout:timeout];
    return textField;
}

#pragma mark - Actions View

- (XCUIElement *)findActionsButton
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:nil
                                                   timeout:kUITestsBaseTimeout];
    XCUIElement *actionsButton = navBar.buttons[@"Share"];
    return actionsButton;
}

- (XCUIElement *)findActionsButtonOnNavBarWithLabel:(NSString *)label
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:label
                                                   timeout:kUITestsBaseTimeout];
    XCUIElement *actionsButton = navBar.buttons[@"Share"];
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
    XCUIElement *actionsButton = navBar.buttons[@"Share"];
    [self waitElement:actionsButton
              visible:true
              timeout:timeout];
    return actionsButton;
}

#pragma mark - Other buttons

- (XCUIElement *)waitMenuButtonWithTimeout:(NSTimeInterval)timeout
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:nil
                                                   timeout:timeout];
    XCUIElement *menuButton = navBar.buttons[@"menu icon"];
    [self waitElement:menuButton
              visible:true
              timeout:timeout];
    return menuButton;
}

- (XCUIElement *)waitDoneButtonWithTimeout:(NSTimeInterval)timeout
{
    return [self waitButtonWithAccessibilityId:@"Done"
                                       visible:true
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

@end