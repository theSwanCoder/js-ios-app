//
// Created by Aleksandr Dakhno on 9/1/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Helpers)
- (void)waitElement:(XCUIElement *)element
            visible:(BOOL)visible
            timeout:(NSTimeInterval)timeout;

- (XCUIElement *)waitNavigationBarWithLabel:(NSString *)label
                                    timeout:(NSTimeInterval)timeout;

// Other elements
- (XCUIElement *)findElementWithAccessibilityId:(NSString *)accessibilityId;
- (XCUIElement *)findElementWithAccessibilityId:(NSString *)accessibilityId
                                  parentElement:(XCUIElement *)parentElement;
- (XCUIElement *)waitElementWithAccessibilityId:(NSString *)accessibilityId
                                        timeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitElementWithAccessibilityId:(NSString *)accessibilityId
                                        visible:(BOOL)visible
                                        timeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitElementWithAccessibilityId:(NSString *)accessibilityId
                                  parentElement:(XCUIElement *)parentElement
                                        visible:(BOOL)visible
                                        timeout:(NSTimeInterval)timeout;
// Buttons
- (XCUIElement *)findButtonWithAccessibilityId:(NSString *)accessibilityId;
- (XCUIElement *)findButtonWithAccessibilityId:(NSString *)accessibilityId
                                 parentElement:(XCUIElement *)parentElement;
- (XCUIElement *)waitButtonWithAccessibilityId:(NSString *)accessibilityId
                                       timeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitButtonWithAccessibilityId:(NSString *)accessibilityId
                                       visible:(BOOL)visible
                                       timeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitButtonWithAccessibilityId:(NSString *)accessibilityId
                                 parentElement:(XCUIElement *)parentElement
                                       visible:(BOOL)visible
                                       timeout:(NSTimeInterval)timeout;
// Back buttons
- (XCUIElement *)waitBackButtonWithAccessibilityId:(NSString *)accessibilityId
                                           timeout:(NSTimeInterval)timeout;
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
// Menu Actions
- (XCUIElement *)findActionsButton;
- (XCUIElement *)findActionsButtonOnNavBarWithLabel:(NSString *)label;
- (XCUIElement *)waitActionsButtonWithTimeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitActionsButtonOnNavBarWithLabel:(NSString *)label
                                            timeout:(NSTimeInterval)timeout;
// Other buttons
- (XCUIElement *)waitMenuButtonWithTimeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitDoneButtonWithTimeout:(NSTimeInterval)timeout;

// Cells
- (NSInteger)countCellsWithAccessibilityId:(NSString *)accessibilityId;
- (XCUIElement *)cellWithAccessibilityId:(NSString *)accessibilityId forIndex:(NSUInteger)index;
@end