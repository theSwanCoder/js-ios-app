//
// Created by Aleksandr Dakhno on 12/10/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+Helpers.h"


@implementation JMBaseUITestCase (Buttons)

- (XCUIElement *)buttonWithId:(NSString *)buttonId
                parentElement:(XCUIElement *)parentElement
                  shouldCheck:(BOOL)shouldCheck
{
    XCUIElement *button = [self waitElementMatchingType:XCUIElementTypeButton
                                             identifier:buttonId
                                          parentElement:parentElement
                                                timeout:kUITestsBaseTimeout];
    if (!button.exists && shouldCheck) {
        NSLog(@"All buttons: %@", self.application.buttons.allElementsBoundByAccessibilityElement);
        XCTFail(@"Button with id: %@, wasn't found", buttonId);
    }
    return button;
}

- (XCUIElement *)buttonWithText:(NSString *)text
                  parentElement:(XCUIElement *)parentElement
                    shouldCheck:(BOOL)shouldCheck
{
    XCUIElement *button = [self waitElementMatchingType:XCUIElementTypeButton
                                                   text:text
                                          parentElement:parentElement
                                                timeout:0]; // It's suggested that element on which button lies have been already found
    if (!button.exists && shouldCheck) {
        NSLog(@"All buttons: %@", self.application.buttons.allElementsBoundByAccessibilityElement);
        XCTFail(@"Button with text: %@, wasn't found", text);
    }
    return button;
}

#pragma mark - Actions

- (void)tapButtonWithId:(NSString *)buttonId
          parentElement:(XCUIElement *)parentElement
            shouldCheck:(BOOL)shouldCheck
{
    XCUIElement *button = [self buttonWithId:buttonId
                               parentElement:parentElement
                                 shouldCheck:shouldCheck];
    if (button.exists) {
        [button tap];
    }
}

- (void)tapButtonWithText:(NSString *)text
            parentElement:(XCUIElement *)parentElement
              shouldCheck:(BOOL)shouldCheck
{
    XCUIElement *button = [self buttonWithText:text
                               parentElement:parentElement
                                 shouldCheck:shouldCheck];
    if (button.exists) {
        [button tap];
    }
}

- (void)verifyButtonExistWithId:(NSString *)buttonId parentElement:(XCUIElement *)parentElement
{
    XCUIElement *button = [self waitElementMatchingType:XCUIElementTypeButton
                                             identifier:buttonId
                                          parentElement:parentElement
                                                timeout:kUITestsBaseTimeout];
    if (!button.exists) {
        NSLog(@"All buttons: %@", self.application.buttons.allElementsBoundByAccessibilityElement);
        XCTFail(@"Button with id: %@, wasn't found", buttonId);
    }
}

- (void)verifyButtonExistWithText:(NSString *)text parentElement:(XCUIElement *)parentElement
{
    XCUIElement *button = [self waitElementMatchingType:XCUIElementTypeButton
                                                   text:text
                                          parentElement:parentElement
                                                timeout:0]; // It's suggested that element on which button lies have been already found
    if (!button.exists) {
        NSLog(@"All buttons: %@", self.application.buttons.allElementsBoundByAccessibilityElement);
        XCTFail(@"Button with text: %@, wasn't found", text);
    }
}

#pragma mark - Named Buttons on Nav Bar

- (void)tapCancelButtonOnNavBarWithTitle:(NSString *)navBarTitle
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:navBarTitle];
    [self tapButtonWithText:JMLocalizedString(@"dialog_button_cancel")
              parentElement:navBar
                shouldCheck:YES];
}

- (void)verifyCancelButtonExistOnNavBarWithTitle:(NSString *)navBarTitle
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:navBarTitle];
    [self verifyButtonExistWithText:JMLocalizedString(@"dialog_button_cancel")
                      parentElement:navBar];
}

- (void)tapDoneButtonOnNavBarWithTitle:(NSString *)navBarTitle
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:navBarTitle];
    [self tapButtonWithText:@"Done"
              parentElement:navBar
                shouldCheck:YES];
}

- (void)verifyDoneButtonExistOnNavBarWithTitle:(NSString *)navBarTitle
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:navBarTitle];
    [self verifyButtonExistWithText:@"Done"
                      parentElement:navBar];
}

- (void)tapBackButtonWithAlternativeTitle:(NSString *)alternativeTitle onNavBarWithTitle:(NSString *)navBarTitle
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:navBarTitle];
    XCUIElement *button = [self waitElementMatchingType:XCUIElementTypeButton
                                                   text:JMLocalizedString(@"back_button_title")
                                          parentElement:navBar
                                                timeout:0];
    if (!button.exists) {
        button = [self waitElementMatchingType:XCUIElementTypeButton
                                          text:alternativeTitle
                                 parentElement:navBar
                                       timeout:0];
    }

    if (button.exists) {
        [button tap];
    } else {
        NSLog(@"All buttons: %@", self.application.buttons.allElementsBoundByAccessibilityElement);
        XCTFail(@"Back Button wasn't found");
    }
}

- (void)verifyBackButtonExistWithAlternativeTitle:(NSString *)alternativeTitle onNavBarWithTitle:(NSString *)navBarTitle
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:navBarTitle];
    XCUIElement *button = [self waitElementMatchingType:XCUIElementTypeButton
                                                   text:JMLocalizedString(@"back_button_title")
                                          parentElement:navBar
                                                timeout:0];
    if (!button.exists) {
        button = [self waitElementMatchingType:XCUIElementTypeButton
                                          text:alternativeTitle
                                 parentElement:navBar
                                       timeout:0];
    }

    if (!button.exists) {
        NSLog(@"All buttons: %@", self.application.buttons.allElementsBoundByAccessibilityElement);
        XCTFail(@"Back Button wasn't found");
    }
}

#pragma mark - Menu Button
- (XCUIElement *)findMenuButtonOnNavBarWithTitle:(NSString *)navBarTitle
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:navBarTitle];
    XCUIElement *menuButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                 identifier:@"menu icon"
                                              parentElement:navBar
                                                    timeout:0];
    if (!menuButton) {
        menuButton = [self waitElementMatchingType:XCUIElementTypeButton
                                        identifier:@"menu icon note"
                                     parentElement:navBar
                                           timeout:0];
    }
    return menuButton;
}

@end