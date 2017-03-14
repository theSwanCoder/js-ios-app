/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Buttons)
- (XCUIElement *)buttonWithId:(NSString *)buttonId parentElement:(XCUIElement *)parentElement shouldCheck:(BOOL)shouldExist;
- (XCUIElement *)buttonWithText:(NSString *)text parentElement:(XCUIElement *)parentElement shouldCheck:(BOOL)shouldExist;

// Actions
- (void)tapButtonWithId:(NSString *)buttonId parentElement:(XCUIElement *)parentElement shouldCheck:(BOOL)shouldCheck;
- (void)tapButtonWithText:(NSString *)text parentElement:(XCUIElement *)parentElement shouldCheck:(BOOL)shouldCheck;
- (void)verifyButtonExistWithId:(NSString *)buttonId parentElement:(XCUIElement *)parentElement;
- (void)verifyButtonExistWithText:(NSString *)text parentElement:(XCUIElement *)parentElement;

// Named Buttons on Nav Bar
- (void)tapCancelButtonOnNavBarWithTitle:(NSString *)navBarTitle;
- (void)verifyCancelButtonExistOnNavBarWithTitle:(NSString *)navBarTitle;
- (void)tapDoneButtonOnNavBarWithTitle:(NSString *)navBarTitle;
- (void)verifyDoneButtonExistOnNavBarWithTitle:(NSString *)navBarTitle;
- (void)tapBackButtonWithAlternativeTitle:(NSString *)alternativeTitle onNavBarWithTitle:(NSString *)navBarTitle;
- (void)verifyBackButtonExistWithAlternativeTitle:(NSString *)alternativeTitle onNavBarWithTitle:(NSString *)navBarTitle;

// Menu Button
- (XCUIElement *)findMenuButtonOnNavBarWithTitle:(NSString *)navBarTitle;

@end
