//
// Created by Aleksandr Dakhno on 12/10/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+TextFields.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Buttons.h"
#import "XCUIElement+Tappable.h"


@implementation JMBaseUITestCase (TextFields)

- (void)closeKeyboardWithDoneButton
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self tapButtonWithText:@"Done"
              parentElement:nil
                shouldCheck:YES];
}

- (void)enterText:(NSString *)text intoTextFieldWithAccessibilityId:(NSString *)accessibilityId
 placeholderValue:(NSString *)placeholderValue
    parentElement:(XCUIElement *)parentElement
    isSecureField:(BOOL)isSecureField
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *textField;
    if (isSecureField) {
        textField =  [self waitElementMatchingType:XCUIElementTypeSecureTextField
                                        identifier:accessibilityId
                                     parentElement:parentElement
                                   filterPredicate:nil
                                           timeout:0];
    } else {
        // TODO: do we need placeholder yet?
        textField =  [self waitElementMatchingType:XCUIElementTypeTextField
                                        identifier:accessibilityId
                                     parentElement:parentElement
                                   filterPredicate:nil
                                           timeout:0];
    }

    if (textField.exists) {
        [self enterText:text
          intoTextField:textField];
    } else {
        XCTFail(@"Can't find text field with id:%@ to enter text: %@", accessibilityId, text);
    }
}

- (void)enterText:(NSString *)text
    intoTextField:(XCUIElement *)textField
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [textField tapByWaitingHittable];
    NSString *oldValueString = textField.value;
    BOOL isTextFieldContainText = oldValueString.length > 0;
    BOOL isTextFieldContainTheSameText = [oldValueString isEqualToString:text];

    if (isTextFieldContainText) {
        if (isTextFieldContainTheSameText) {
            [self closeKeyboardWithDoneButton];
        } else {
            [self replaceTextInTextField:textField
                                withText:text];
        }
    } else {
        [textField typeText:text];
        [self closeKeyboardWithDoneButton];
    }
}

- (void)replaceTextInTextField:(XCUIElement *)textField
                      withText:(NSString *)text
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self deleteTextFromTextField:textField];
    [textField typeText:text];
    [self closeKeyboardWithDoneButton];
}

- (void)deleteTextFromTextField:(XCUIElement *)textField
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSString *oldValueString = textField.value;
    XCUIElement *keyboard = [self.application.keyboards elementBoundByIndex:0];
    XCUIElement *deleteSymbolButton = keyboard.keys[@"delete"];
    if (deleteSymbolButton.exists) {
        for (int i = 0; i < oldValueString.length; ++i) {
            [deleteSymbolButton tapByWaitingHittable];
        }
    }
}

@end
