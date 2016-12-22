//
// Created by Aleksandr Dakhno on 12/10/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+Helpers.h"
#import "XCUIElement+Tappable.h"


@implementation JMBaseUITestCase (Buttons)

- (XCUIElement *)buttonWithId:(NSString *)buttonId
                parentElement:(XCUIElement *)parentElement
                  shouldCheck:(BOOL)shouldCheck
{
    NSTimeInterval timeout = 0;
    if (shouldCheck) {
        timeout = kUITestsElementAvailableTimeout;
    }
    XCUIElement *button = [self waitElementMatchingType:XCUIElementTypeButton
                                             identifier:buttonId
                                          parentElement:parentElement
                                        filterPredicate:nil
                                                timeout:timeout];
    if (!button.exists && shouldCheck) {
        [self performTestFailedWithErrorMessage:[NSString stringWithFormat:@"Button with id: %@, wasn't found", buttonId]
                                     logMessage:[NSString stringWithFormat:@"All buttons: %@", self.application.buttons.allElementsBoundByAccessibilityElement]];
    }
    return button;
}

- (XCUIElement *)buttonWithText:(NSString *)text
                  parentElement:(XCUIElement *)parentElement
                    shouldCheck:(BOOL)shouldCheck
{
    NSTimeInterval timeout = 0;
    if (shouldCheck) {
        timeout = kUITestsElementAvailableTimeout;
    }
    XCUIElement *button = [self waitElementMatchingType:XCUIElementTypeButton
                                                   text:text
                                          parentElement:parentElement
                                                timeout:timeout]; // It's suggested that element on which button lies have been already found
    if (!button.exists && shouldCheck) {
        [self performTestFailedWithErrorMessage:[NSString stringWithFormat:@"Button with text: %@, wasn't found", text]
                                     logMessage:[NSString stringWithFormat:@"All buttons: %@", self.application.buttons.allElementsBoundByAccessibilityElement]];
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
        [button tapByWaitingHittable];
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
        [button tapByWaitingHittable];
    }
}

- (void)verifyButtonExistWithId:(NSString *)buttonId parentElement:(XCUIElement *)parentElement
{
    XCUIElement *button = [self waitElementMatchingType:XCUIElementTypeButton
                                             identifier:buttonId
                                          parentElement:parentElement
                                        filterPredicate:nil
                                                timeout:kUITestsElementAvailableTimeout];
    if (!button.exists) {
        [self performTestFailedWithErrorMessage:[NSString stringWithFormat:@"Button with id: %@, wasn't found", buttonId]
                                     logMessage:[NSString stringWithFormat:@"All buttons: %@", self.application.buttons.allElementsBoundByAccessibilityElement]];
    }
}

- (void)verifyButtonExistWithText:(NSString *)text parentElement:(XCUIElement *)parentElement
{
    XCUIElement *button = [self waitElementMatchingType:XCUIElementTypeButton
                                                   text:text
                                          parentElement:parentElement
                                                timeout:kUITestsElementAvailableTimeout]; // It's suggested that element on which button lies have been already found
    if (!button.exists) {
        [self performTestFailedWithErrorMessage:[NSString stringWithFormat:@"Button with text: %@, wasn't found", text]
                                     logMessage:[NSString stringWithFormat:@"All buttons: %@", self.application.buttons.allElementsBoundByAccessibilityElement]];
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
                                                timeout:kUITestsElementAvailableTimeout];
    if (!button.exists && alternativeTitle) {
        button = [self waitElementMatchingType:XCUIElementTypeButton
                                          text:alternativeTitle
                                 parentElement:navBar
                                       timeout:kUITestsElementAvailableTimeout];
    }

    if (button.exists) {
        [button tapByWaitingHittable];
    } else {
        [self performTestFailedWithErrorMessage:[NSString stringWithFormat:@"Back Button wasn't found"]
                                     logMessage:[NSString stringWithFormat:@"All buttons: %@", self.application.buttons.allElementsBoundByAccessibilityElement]];
    }
}

- (void)verifyBackButtonExistWithAlternativeTitle:(NSString *)alternativeTitle onNavBarWithTitle:(NSString *)navBarTitle
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:navBarTitle];
    XCUIElement *button = [self waitElementMatchingType:XCUIElementTypeButton
                                                   text:JMLocalizedString(@"back_button_title")
                                          parentElement:navBar
                                                timeout:kUITestsElementAvailableTimeout];
    if (!button.exists) {
        button = [self waitElementMatchingType:XCUIElementTypeButton
                                          text:alternativeTitle
                                 parentElement:navBar
                                       timeout:kUITestsElementAvailableTimeout];
    }

    if (!button.exists) {
        [self performTestFailedWithErrorMessage:[NSString stringWithFormat:@"Back Button wasn't found"]
                                     logMessage:[NSString stringWithFormat:@"All buttons: %@", self.application.buttons.allElementsBoundByAccessibilityElement]];
    }
}

#pragma mark - Menu Button
- (XCUIElement *)findMenuButtonOnNavBarWithTitle:(NSString *)navBarTitle
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:navBarTitle];
    XCUIElement *menuButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                 identifier:@"menu icon"
                                              parentElement:navBar
                                            filterPredicate:nil
                                                    timeout:kUITestsElementAvailableTimeout];
    if (!menuButton) {
        menuButton = [self waitElementMatchingType:XCUIElementTypeButton
                                        identifier:@"menu icon note"
                                     parentElement:navBar
                                   filterPredicate:nil
                                           timeout:kUITestsElementAvailableTimeout];
    }
    return menuButton;
}

@end