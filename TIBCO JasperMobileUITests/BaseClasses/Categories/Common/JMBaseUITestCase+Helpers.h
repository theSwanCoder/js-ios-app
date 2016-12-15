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
                                 timeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                              identifier:(NSString *)identifier
                           parentElement:(XCUIElement *)parentElement
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

// Cells
- (NSInteger)countCellsWithAccessibilityId:(NSString *)accessibilityId;
- (XCUIElement *)cellWithAccessibilityId:(NSString *)accessibilityId forIndex:(NSUInteger)index;
- (XCUIElement *)findCollectionViewCellWithAccessibilityId:(NSString *)accessibilityId
                          containsLabelWithAccessibilityId:(NSString *)labelAccessibilityId
                                                 labelText:(NSString *)labelText;
- (XCUIElement *)waitCollectionViewCellWithAccessibilityId:(NSString *)accessibilityId
                          containsLabelWithAccessibilityId:(NSString *)labelAccessibilityId
                                                 labelText:(NSString *)labelText
                                                   timeout:(NSTimeInterval)timeout;
- (XCUIElement *)findTableViewCellWithAccessibilityId:(NSString *)accessibilityId
                                containsLabelWithText:(NSString *)labelText;
// Search
- (void)searchInMultiSelectedInputControlWithText:(NSString *)searchText;

// Alerts
- (XCUIElement *)findAlertWithTitle:(NSString *)title;
- (XCUIElement *)waitAlertWithTitle:(NSString *)title timeout:(NSTimeInterval)timeout;

// Images
- (XCUIElement *)findImageWithAccessibilityId:(NSString *)accessibilityId;
@end
