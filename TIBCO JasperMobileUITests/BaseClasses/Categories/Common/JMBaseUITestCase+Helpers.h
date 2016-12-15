//
// Created by Aleksandr Dakhno on 9/1/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Helpers)

// Waitings
- (void)waitElementReady:(XCUIElement *)element
                 timeout:(NSTimeInterval)timeout;

// NavigationBars
- (XCUIElement *)findNavigationBarWithLabel:(NSString *)label;
- (XCUIElement *)waitNavigationBarWithLabel:(NSString *)label
                                    timeout:(NSTimeInterval)timeout;

// Elements with identifiers
- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                              identifier:(NSString *)identifier
                                 timeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                              identifier:(NSString *)identifier
                           parentElement:(XCUIElement *)parentElement
                         filterPredicate:(NSPredicate *)filterPredicate
                                 timeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                              identifier:(NSString *)identifier
                           parentElement:(XCUIElement *)parentElement
                         filterPredicate:(NSPredicate *)filterPredicate
                     shouldBeInHierarchy:(BOOL)shouldBeInHierarchy
                                 timeout:(NSTimeInterval)timeout;

// Elements with text
- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                                    text:(NSString *)text
                                 timeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                                    text:(NSString *)text
                           parentElement:(XCUIElement *)parentElement
                                 timeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                                    text:(NSString *)text
                           parentElement:(XCUIElement *)parentElement
                     shouldBeInHierarchy:(BOOL)shouldBeInHierarchy
                                 timeout:(NSTimeInterval)timeout;

// Search
- (void)searchInMultiSelectedInputControlWithText:(NSString *)searchText;

// Alerts
- (XCUIElement *)findAlertWithTitle:(NSString *)title;
- (XCUIElement *)waitAlertWithTitle:(NSString *)title timeout:(NSTimeInterval)timeout;

// Images
- (XCUIElement *)findImageWithAccessibilityId:(NSString *)accessibilityId;
@end
