//
// Created by Aleksandr Dakhno on 9/1/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Helpers)
- (void)waitElementReady:(XCUIElement *)element
                 timeout:(NSTimeInterval)timeout;
- (void)waitElementReady:(XCUIElement *)element
                 visible:(BOOL)visible
                 timeout:(NSTimeInterval)timeout;

// NavigationBars
- (XCUIElement *)findNavigationBarWithLabel:(NSString *)label;
- (XCUIElement *)waitNavigationBarWithLabel:(NSString *)label
                                    timeout:(NSTimeInterval)timeout;

// Other elements
- (XCUIElement *)findElementWithAccessibilityId:(NSString *)accessibilityId;
- (XCUIElement *)waitElementWithAccessibilityId:(NSString *)accessibilityId
                                        timeout:(NSTimeInterval)timeout;

- (XCUIElement *)findElementWithAccessibilityId:(NSString *)accessibilityId
                                  parentElement:(XCUIElement *)parentElement;
- (XCUIElement *)waitElementWithAccessibilityId:(NSString *)accessibilityId
                                  parentElement:(XCUIElement *)parentElement
                                        timeout:(NSTimeInterval)timeout;

- (XCUIElement *)waitElementWithAccessibilityId:(NSString *)accessibilityId
                                  parentElement:(XCUIElement *)parentElement
                                        visible:(BOOL)visible
                                        timeout:(NSTimeInterval)timeout;
// Buttons
- (XCUIElement *)findButtonWithAccessibilityId:(NSString *)accessibilityId;
- (XCUIElement *)waitButtonWithAccessibilityId:(NSString *)accessibilityId
                                       timeout:(NSTimeInterval)timeout;
- (XCUIElement *)findButtonWithAccessibilityId:(NSString *)accessibilityId
                                 parentElement:(XCUIElement *)parentElement;
- (XCUIElement *)waitButtonWithAccessibilityId:(NSString *)accessibilityId
                                 parentElement:(XCUIElement *)parentElement
                                       timeout:(NSTimeInterval)timeout;
- (XCUIElement *)findButtonWithTitle:(NSString *)title;
- (XCUIElement *)waitButtonWithTitle:(NSString *)title
                             timeout:(NSTimeInterval)timeout;
- (XCUIElement *)findButtonWithTitle:(NSString *)title
                       parentElement:(XCUIElement *)parentElement;
- (XCUIElement *)waitButtonWithTitle:(NSString *)title
                       parentElement:(XCUIElement *)parentElement
                             timeout:(NSTimeInterval)timeout;
// Back buttons
- (XCUIElement *)findBackButtonWithAccessibilityId:(NSString *)accessibilityId;
- (XCUIElement *)waitBackButtonWithAccessibilityId:(NSString *)accessibilityId
                                           timeout:(NSTimeInterval)timeout;
- (XCUIElement *)findBackButtonWithAccessibilityId:(NSString *)accessibilityId
                                 onNavBarWithLabel:(NSString *)label;
- (XCUIElement *)waitBackButtonWithAccessibilityId:(NSString *)accessibilityId
                                 onNavBarWithLabel:(NSString *)label
                                           timeout:(NSTimeInterval)timeout;
// Text Fields
- (XCUIElement *)waitTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                          timeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                    parentElement:(XCUIElement *)parentElement
                                          timeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitSecureTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                                timeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitSecureTextFieldWithAccessibilityId:(NSString *)accessibilityId
                                          parentElement:(XCUIElement *)parentElement
                                                timeout:(NSTimeInterval)timeout;
// Static Text
- (XCUIElement *)findStaticTextWithAccessibilityId:(NSString *)accessibilityId;
- (XCUIElement *)waitStaticTextWithAccessibilityId:(NSString *)accessibilityId
                                           timeout:(NSTimeInterval)timeout;

- (XCUIElement *)findStaticTextWithAccessibilityId:(NSString *)accessibilityId
                                     parentElement:(XCUIElement *)parentElement;
- (XCUIElement *)waitStaticTextWithAccessibilityId:(NSString *)accessibilityId
                                     parentElement:(XCUIElement *)parentElement
                                           timeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitStaticTextWithAccessibilityId:(NSString *)accessibilityId
                                     parentElement:(XCUIElement *)parentElement
                                           visible:(BOOL)visible
                                           timeout:(NSTimeInterval)timeout;

- (XCUIElement *)findStaticTextWithText:(NSString *)text;
- (XCUIElement *)findStaticTextWithText:(NSString *)text
                          parentElement:(XCUIElement *)parentElement;
- (XCUIElement *)waitStaticTextWithText:(NSString *)text
                          parentElement:(XCUIElement *)parentElement
                                timeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitStaticTextWithText:(NSString *)text
                          parentElement:(XCUIElement *)parentElement
                                visible:(BOOL)visible
                                timeout:(NSTimeInterval)timeout;

// Other buttons
- (XCUIElement *)waitMenuButtonWithTimeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitDoneButtonWithTimeout:(NSTimeInterval)timeout;

// Cells
- (NSInteger)countCellsWithAccessibilityId:(NSString *)accessibilityId;
- (XCUIElement *)cellWithAccessibilityId:(NSString *)accessibilityId forIndex:(NSUInteger)index;
- (XCUIElement *)findCollectionViewCellWithAccessibilityId:(NSString *)accessibilityId
                          containsLabelWithAccessibilityId:(NSString *)labelAccessibilityId
                                                 labelText:(NSString *)labelText;
- (XCUIElement *)findTableViewCellWithAccessibilityId:(NSString *)accessibilityId
                                containsLabelWithText:(NSString *)labelText;
// Search
- (void)searchInMultiSelectedInputControlWithText:(NSString *)searchText;

// Alerts
- (XCUIElement *)findAlertWithTitle:(NSString *)title;
- (XCUIElement *)waitAlertWithTitle:(NSString *)title timeout:(NSTimeInterval)timeout;
@end
