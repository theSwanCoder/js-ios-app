//
// Created by Aleksandr Dakhno on 12/10/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

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