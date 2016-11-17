//
// Created by Aleksandr Dakhno on 9/1/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Helpers.h"

@implementation JMBaseUITestCase (Helpers)

- (void)waitElementReady:(XCUIElement *)element
                 timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self waitElementReady:element
                   visible:true
                   timeout:timeout];
}

- (void)waitElementReady:(XCUIElement *)element
                 visible:(BOOL)visible
                 timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    if (element.exists == visible) {
        return;
    }
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

- (XCUIElement *)waitElementInHierarchyWithAccessibilityId:(NSString *)accessibilityId
                                                   timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSTimeInterval remain = timeout;
    XCUIElement *element;
    do {
        remain -= kUITestsElementAvailableTimeout;
        sleep(kUITestsElementAvailableTimeout);
        XCUIElementQuery *elementQuery = [self.application.otherElements matchingIdentifier:accessibilityId];
        NSArray *allElements = elementQuery.allElementsBoundByAccessibilityElement;
        NSLog(@"For id '%@' all found elements: %@", accessibilityId, allElements);
        element = allElements.firstObject;
    } while (element == nil && remain >= 0);

    if (element == nil) {
        XCTFail(@"Element with id '%@' not found", accessibilityId);
    }
    return element;
}

- (XCUIElement *)waitButtonInHierarchyWithAccessiblitiyId:(NSString *)accessibilityId
                                                  timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSTimeInterval remain = timeout;
    XCUIElement *button;
    do {
        remain -= kUITestsElementAvailableTimeout;
        sleep(kUITestsElementAvailableTimeout);
        XCUIElementQuery *elementQuery = [self.application.buttons matchingIdentifier:accessibilityId];
        NSArray *allElements = elementQuery.allElementsBoundByAccessibilityElement;
        NSLog(@"For id '%@' all found elements: %@", accessibilityId, allElements);
        button = allElements.firstObject;
    } while (button == nil && remain >= 0);

    if (button == nil) {
        XCTFail(@"Button with id '%@' not found", accessibilityId);
    }
    return button;
}

- (XCUIElement *)waitButtonInHierarchyWithTitle:(NSString *)title
                                        timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSTimeInterval remain = timeout;
    XCUIElement *button;
    do {
        remain -= kUITestsElementAvailableTimeout;
        sleep(kUITestsElementAvailableTimeout);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like %@", @"label", title];
        XCUIElementQuery *elementQuery = [self.application.buttons matchingPredicate:predicate];
        NSArray *allElements = elementQuery.allElementsBoundByAccessibilityElement;
        NSLog(@"For title '%@' all found elements: %@", title, allElements);
        button = allElements.firstObject;
    } while (button == nil && remain >= 0);

    if (button == nil) {
        XCTFail(@"Button with title '%@' not found", title);
    }
    return button;
}

- (XCUIElement *)waitAlertInHierarchyWithTitle:(NSString *)title
                                       timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSTimeInterval remain = timeout;
    XCUIElement *alert;
    do {
        remain -= kUITestsElementAvailableTimeout;
        sleep(kUITestsElementAvailableTimeout);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title like %@", title];
        XCUIElementQuery *elementQuery = [self.application.alerts matchingPredicate:predicate];
        NSArray *allElements = elementQuery.allElementsBoundByAccessibilityElement;
        NSLog(@"All found alerts with title '%@': %@", title, allElements);
        alert = allElements.firstObject;
    } while (alert == nil && remain >= 0);

    if (alert == nil) {
        XCTFail(@"Alert with title '%@' not found", title);
    }
    return alert;
}

- (XCUIElement *)waitStaticTextInHierarchyWithText:(NSString *)text
                                     parentElement:(XCUIElement *)parentElement
                                           timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSTimeInterval remain = timeout;
    XCUIElement *staticText;
    do {
        remain -= kUITestsElementAvailableTimeout;
        sleep(kUITestsElementAvailableTimeout);
        if (parentElement == nil) {
            parentElement = self.application;
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label CONTAINS %@", text];
        XCUIElementQuery *query = [parentElement.staticTexts matchingPredicate:predicate];
        NSArray *elements = query.allElementsBoundByAccessibilityElement;
        NSLog(@"All static texts: %@", elements);
        staticText = elements.firstObject;
    } while (staticText == nil && remain >= 0);

    if (staticText == nil) {
        XCTFail(@"Static text with text '%@' not found", text);
    }
    return staticText;
}

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
    XCUIElement *navBar = [self findNavigationBarWithLabel:label];
    [self waitElementReady:navBar
                   timeout:timeout];
    return navBar;
}

#pragma mark - General Elements
- (XCUIElement *)elementWithAccessibilityId:(NSString *)accessibilityId
                              parentElement:(XCUIElement *)parentElement
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self findElementWithAccessibilityId:accessibilityId
                                  parentElement:nil];
}

- (XCUIElement *)waitElementWithAccessibilityId:(NSString *)accessibilityId
                                        timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self waitElementWithAccessibilityId:accessibilityId
                                  parentElement:nil
                                        timeout:timeout];
}

- (XCUIElement *)findElementWithAccessibilityId:(NSString *)accessibilityId
                                  parentElement:(XCUIElement *)parentElement
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *element = [self elementWithAccessibilityId:accessibilityId
                                              parentElement:parentElement];
    if (!element && visible) {
        element = [self waitElementInHierarchyWithAccessibilityId:accessibilityId
                                                          timeout:timeout];
    }
    
    if (element) {
        [self waitElementReady:element
                       visible:visible
                       timeout:timeout];
    }
    
    return element;
}

#pragma mark - General Buttons

- (XCUIElement *)findButtonWithAccessibilityId:(NSString *)accessibilityId
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self findButtonWithAccessibilityId:accessibilityId
                                 parentElement:nil];
}

- (XCUIElement *)waitButtonWithAccessibilityId:(NSString *)accessibilityId
                                       timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self waitButtonWithAccessibilityId:accessibilityId
                                 parentElement:nil
                                       timeout:timeout];
}

- (XCUIElement *)buttonWithAccessibilityId:(NSString *)accessibilityId
                             parentElement:(XCUIElement *)parentElement
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *button = [self buttonWithAccessibilityId:accessibilityId
                                            parentElement:parentElement];
    if (!button) {
        button = [self waitButtonInHierarchyWithAccessiblitiyId:accessibilityId
                                                        timeout:timeout];
    }
    [self waitElementReady:button
                   timeout:timeout];
    [self waitButtonIsHittable:button];
    return button;
}

- (XCUIElement *)findButtonWithTitle:(NSString *)title
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self findButtonWithTitle:title
                       parentElement:nil];
}

- (XCUIElement *)waitButtonWithTitle:(NSString *)title
                             timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self waitButtonWithTitle:title
                       parentElement:nil
                             timeout:timeout];
}

- (XCUIElement *)findButtonWithTitle:(NSString *)title
                       parentElement:(XCUIElement *)parentElement
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *button = [self buttonWithTitle:title
                                  parentElement:parentElement];
    if (!button) {
        return nil;
    }
    if (!button.exists || !button.isHittable) {
        // API looks like it is sync, but we need this here because an element has to be prepeared before return
        [self waitElementReady:button
                       timeout:kUITestsBaseTimeout];
        [self waitButtonIsHittable:button];
    }
    return button;
}

- (XCUIElement *)waitButtonWithTitle:(NSString *)title
                       parentElement:(XCUIElement *)parentElement
                             timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *button = [self buttonWithTitle:title
                                  parentElement:parentElement];
    if (!button) {
        button = [self waitButtonInHierarchyWithTitle:title
                                              timeout:timeout];
    }
    [self waitElementReady:button
                   timeout:timeout];
    [self waitButtonIsHittable:button];
    return button;
}

- (XCUIElement *)buttonWithTitle:(NSString *)title
                   parentElement:(XCUIElement *)parentElement
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    if (parentElement == nil) {
        parentElement = self.application;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like %@", @"label", title];
    XCUIElementQuery *buttonsQuery = [parentElement.buttons matchingPredicate:predicate];
    NSArray *allMatchingButtons = buttonsQuery.allElementsBoundByAccessibilityElement;
    NSLog(@"allMatchingButtons: %@", allMatchingButtons);
    if (allMatchingButtons.count == 0) {
        return nil;
    } else if (allMatchingButtons.count > 1) {
        // TODO: should this be interpreted as an error?
        NSLog(@"Several button with the same title: %@", title);
    }
    return allMatchingButtons.firstObject;
}

- (void)waitButtonIsHittable:(XCUIElement *)button
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self findBackButtonWithAccessibilityId:accessibilityId
                                 onNavBarWithLabel:nil];
}

- (XCUIElement *)waitBackButtonWithAccessibilityId:(NSString *)accessibilityId
                                           timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self waitBackButtonWithAccessibilityId:accessibilityId
                                 onNavBarWithLabel:nil
                                           timeout:timeout];
}

- (XCUIElement *)findBackButtonWithAccessibilityId:(NSString *)accessibilityId
                                 onNavBarWithLabel:(NSString *)label
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *navBar = [self waitNavigationBarWithLabel:label
                                                   timeout:timeout];
    XCUIElement *button = [self waitButtonWithAccessibilityId:accessibilityId
                                                parentElement:navBar
                                                      timeout:timeout];
    return button;
}

#pragma mark - Text Fields

- (XCUIElement *)findTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                 placeholderValue:(NSString *)placeholderValue
                                    parentElement:(XCUIElement *)parentElement
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    if (parentElement == nil) {
        parentElement = self.application;
    }

    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(XCUIElement *evaluatedObject, NSDictionary<NSString *, id> *bindings) {
        
        if (placeholderValue) {
            BOOL isAccessibilityIdsEquals = [evaluatedObject.identifier isEqualToString:accessibilityId];
            BOOL isPlaceholderValuesEquals = [evaluatedObject.placeholderValue isEqualToString:placeholderValue];
            return isAccessibilityIdsEquals || isPlaceholderValuesEquals;
        } else {
            return [evaluatedObject.identifier isEqualToString:accessibilityId];
        }
        
    }];
    XCUIElementQuery *textFieldsQuery = [parentElement.textFields matchingPredicate:predicate];
    NSArray *allMatchingTextFields = textFieldsQuery.allElementsBoundByAccessibilityElement;

    if (allMatchingTextFields.count == 0) {
        return nil;
    } else if (allMatchingTextFields.count > 1) {
        // TODO: should this be interpreted as an error?
        NSLog(@"Several text fields with id: %@", accessibilityId);
    }
    return allMatchingTextFields.firstObject;
}

- (XCUIElement *)findTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                    parentElement:(XCUIElement *)parentElement
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self findTextFieldWithAccessibilityId:accessibilityId
                                 placeholderValue:nil
                                    parentElement:parentElement];
}

- (XCUIElement *)findSecureTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                          parentElement:(XCUIElement *)parentElement
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self waitTextFieldWithAccessibilityId:accessibilityId
                                    parentElement:nil
                                          timeout:timeout];
}

- (XCUIElement *)waitTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                 placeholderValue:(NSString *)placeholderValue
                                    parentElement:(XCUIElement *)parentElement
                                          timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *textField = [self findTextFieldWithAccessibilityId:accessibilityId
                                                   placeholderValue:placeholderValue
                                                      parentElement:parentElement];
    [self waitElementReady:textField
                   timeout:timeout];
    return textField;
}

- (XCUIElement *)waitTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                    parentElement:(XCUIElement *)parentElement
                                          timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self waitTextFieldWithAccessibilityId:accessibilityId
                                 placeholderValue:nil
                                    parentElement:parentElement
                                          timeout:timeout];
}

- (XCUIElement *)waitSecureTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                                timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self waitSecureTextFieldWithAccessibilityId:accessibilityId
                                          parentElement:nil
                                                timeout:timeout];
}

- (XCUIElement *)waitSecureTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                          parentElement:(XCUIElement *)parentElement
                                                timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *textField = [self findSecureTextFieldWithAccessibilityId:accessibilityId
                                                            parentElement:parentElement];
    [self waitElementReady:textField
                   timeout:timeout];
    return textField;
}

#pragma mark - Static Text

- (XCUIElement *)findStaticTextWithAccessibilityId:(NSString *)accessibilityId
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self findStaticTextWithAccessibilityId:accessibilityId
                                     parentElement:nil];
}

- (XCUIElement *)waitStaticTextWithAccessibilityId:(NSString *)accessibilityId
                                           timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self waitStaticTextWithAccessibilityId:accessibilityId
                                     parentElement:nil
                                           timeout:timeout];
}

- (XCUIElement *)findStaticTextWithAccessibilityId:(NSString *)accessibilityId
                                     parentElement:(XCUIElement *)parentElement
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *element = [self findStaticTextWithAccessibilityId:accessibilityId
                                                     parentElement:parentElement];
    [self waitElementReady:element
                   timeout:timeout];
    return element;
}

- (XCUIElement *)waitStaticTextWithAccessibilityId:(NSString *)accessibilityId
                                     parentElement:(XCUIElement *)parentElement
                                           visible:(BOOL)visible
                                           timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *element = [self findStaticTextWithAccessibilityId:accessibilityId
                                                     parentElement:parentElement];
    [self waitElementReady:element
                   visible:visible
                   timeout:timeout];
    return element;
}

- (XCUIElement *)findStaticTextWithText:(NSString *)text
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self findStaticTextWithText:text
                          parentElement:nil];
}

- (XCUIElement *)findStaticTextWithText:(NSString *)text
                          parentElement:(XCUIElement *)parentElement
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    if (parentElement == nil) {
        parentElement = self.application;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label CONTAINS %@", text];
    XCUIElementQuery *query = [parentElement.staticTexts matchingPredicate:predicate];
    NSArray *elements = query.allElementsBoundByAccessibilityElement;
    XCUIElement *element = elements.firstObject;
    return element;
}

- (XCUIElement *)waitStaticTextWithText:(NSString *)text
                          parentElement:(XCUIElement *)parentElement
                                timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *element = [self waitStaticTextWithText:text
                                          parentElement:parentElement
                                                visible:YES
                                                timeout:timeout];
    
    return element;
}

- (XCUIElement *)waitStaticTextWithText:(NSString *)text
                          parentElement:(XCUIElement *)parentElement
                                visible:(BOOL)visible
                                timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *element = [self findStaticTextWithText:text
                                          parentElement:parentElement];

    if (!element) {
        element = [self waitStaticTextInHierarchyWithText:text
                                            parentElement:parentElement
                                                  timeout:timeout];
    }
    [self waitElementReady:element
                   visible:visible
                   timeout:timeout];
    return element;
}

#pragma mark - Other buttons

- (XCUIElement *)waitMenuButtonWithTimeout:(NSTimeInterval)timeout
                         inSectionWithName:(NSString *)sectionName
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *menuButton = [self findMenuButtonInSectionWithName:sectionName];
    [self waitElementReady:menuButton
                   timeout:timeout];
    return menuButton;
}

- (XCUIElement *)findMenuButtonInSectionWithName:(NSString *)sectionName
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *navBar = [self waitNavigationBarWithLabel:sectionName
                                                   timeout:kUITestsBaseTimeout];
    XCUIElement *menuButton = [self findButtonWithAccessibilityId:@"menu icon"
                                                    parentElement:navBar];
    if (!menuButton) {
        menuButton = [self findButtonWithAccessibilityId:@"menu icon note"
                                           parentElement:navBar];
    }
    return menuButton;
}

- (XCUIElement *)waitDoneButtonWithTimeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self waitButtonWithAccessibilityId:@"Done"
                                       timeout:timeout];
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

- (void)searchInMultiSelectedInputControlWithText:(NSString *)searchText
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *searchField = self.application.searchFields[@"Search Values"];
    [self waitElementReady:searchField
                   timeout:kUITestsBaseTimeout];

    [searchField tap];
    [searchField typeText:searchText];

    XCUIElement *searchButton = [self waitButtonWithAccessibilityId:@"Search"
                                                            timeout:kUITestsBaseTimeout];
    [searchButton tap];
}

#pragma mark - Alerts

- (XCUIElement *)findAlertWithTitle:(NSString *)title
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElementQuery *alertsQuery = self.application.alerts;
    XCUIElement *alert = [alertsQuery matchingIdentifier:title].element;
    return alert;
}

- (XCUIElement *)waitAlertWithTitle:(NSString *)title timeout:(NSTimeInterval)timeout
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
