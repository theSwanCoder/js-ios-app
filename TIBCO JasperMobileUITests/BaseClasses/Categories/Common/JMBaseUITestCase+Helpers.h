/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

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
// Elemets with predicate
- (XCUIElement *)waitElementMatchingType:(XCUIElementType)elementType
                           parentElement:(XCUIElement *)parentElement
                         filterPredicate:(NSPredicate *)filterPredicate
                                 timeout:(NSTimeInterval)timeout;
- (XCUIElement *)elementMatchingType:(XCUIElementType)elementType
                       parentElement:(XCUIElement *)parentElement
                     filterPredicate:(NSPredicate *)filterPredicate;

// Elements by index
- (XCUIElement *)elementMatchingType:(XCUIElementType)elementType
                          identifier:(NSString *)identifier
                       parentElement:(XCUIElement *)parentElement
                             atIndex:(NSUInteger)index;

- (XCUIElement *)elementMatchingType:(XCUIElementType)elementType
                                text:(NSString *)text
                       parentElement:(XCUIElement *)parentElement
                             atIndex:(NSUInteger)index;

- (XCUIElement *)elementMatchingType:(XCUIElementType)elementType
                       parentElement:(XCUIElement *)parentElement
                             atIndex:(NSUInteger)index;

// Search
- (void)searchInMultiSelectedInputControlWithText:(NSString *)searchText;

// Images
- (XCUIElement *)findImageWithAccessibilityId:(NSString *)accessibilityId;
@end
