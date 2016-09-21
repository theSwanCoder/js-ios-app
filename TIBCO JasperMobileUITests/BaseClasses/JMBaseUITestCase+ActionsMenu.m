//
// Created by Aleksandr Dakhno on 9/7/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Helpers.h"


@implementation JMBaseUITestCase (ActionsMenu)

- (BOOL)isShareButtonExists
{
    XCUIElement *actionsButton = [self findActionsButton];
    return actionsButton.exists;
}

- (XCUIElement *)findActionsButton
{
    return [self findActionsButtonOnNavBarWithLabel:nil];
}

- (XCUIElement *)findActionsButtonOnNavBarWithLabel:(NSString *)label
{
    XCUIElement *navBar;
    if (label) {
        navBar = [self waitNavigationBarWithLabel:label
                                          timeout:kUITestsBaseTimeout];
    }
    XCUIElement *actionsButton = [self findButtonWithAccessibilityId:@"Share"
                                                       parentElement:navBar];
    return actionsButton;
}

- (XCUIElement *)waitActionsButtonWithTimeout:(NSTimeInterval)timeout
{
    return [self waitActionsButtonOnNavBarWithLabel:nil
                                            timeout:timeout];
}

- (XCUIElement *)waitActionsButtonOnNavBarWithLabel:(NSString *)label
                                            timeout:(NSTimeInterval)timeout
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:label
                                                   timeout:timeout];
    XCUIElement *actionsButton = [self waitButtonWithAccessibilityId:@"Share"
                                                       parentElement:navBar
                                                             timeout:timeout];
    return actionsButton;
}

- (void)openMenuActions
{
    [self openMenuActionsOnNavBarWithLabel:nil];
}

- (void)selectActionWithName:(NSString *)actionName
{
    XCUIElement *menuActionsView = [self waitElementWithAccessibilityId:@"JMMenuActionsViewAccessibilityId"
                                                                timeout:kUITestsBaseTimeout];

    XCUIElement *saveButton = menuActionsView.staticTexts[actionName];
    if (saveButton) {
        [saveButton tap];
    } else {
        XCTFail(@"'%@' button isn't visible", actionName);
    }
}

- (void)openMenuActionsOnNavBarWithLabel:(NSString *)label
{
    XCUIElement *actionsButton = [self waitActionsButtonOnNavBarWithLabel:label
                                                                  timeout:kUITestsBaseTimeout];
    [actionsButton tap];
}

@end