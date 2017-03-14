/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (TextFields)
- (void)enterText:(NSString *)text intoTextFieldWithAccessibilityId:(NSString *)accessibilityId
 placeholderValue:(NSString *)placeholderValue
    parentElement:(XCUIElement *)parentElement
    isSecureField:(BOOL)isSecureField;
- (void)enterText:(NSString *)text
    intoTextField:(XCUIElement *)textField;
- (void)deleteTextFromTextField:(XCUIElement *)textField;
- (void)closeKeyboardWithDoneButton;
@end
