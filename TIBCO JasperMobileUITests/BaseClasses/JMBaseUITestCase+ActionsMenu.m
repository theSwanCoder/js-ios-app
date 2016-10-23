//
// Created by Aleksandr Dakhno on 9/7/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Helpers.h"


@implementation JMBaseUITestCase (ActionsMenu)

- (BOOL)isActionsButtonExists
{
    XCUIElement *actionsButton = [self findActionsButtonWithControllerAccessibilityId:nil];
    return actionsButton.exists;
}

- (XCUIElement *)findActionsButtonWithControllerAccessibilityId:(NSString *)controllerAccessibilityId
{
    XCUIElement *navBar = [self waitNavigationBarWithControllerAccessibilityId:controllerAccessibilityId timeout:kUITestsBaseTimeout];
    XCUIElement *actionsButton = [self findButtonWithAccessibilityId:JMMenuActionsViewActionButtonAccessibilityId
                                                       parentElement:navBar];
    return actionsButton;
}

- (XCUIElement *)waitActionsButtonWithControllerAccessibilityId:(NSString *)controllerAccessibilityId
                                                        timeout:(NSTimeInterval)timeout
{
    XCUIElement *navBar = [self waitNavigationBarWithControllerAccessibilityId:controllerAccessibilityId timeout:kUITestsBaseTimeout];
    XCUIElement *actionsButton = [self waitButtonWithAccessibilityId:JMMenuActionsViewActionButtonAccessibilityId
                                                       parentElement:navBar
                                                             timeout:timeout];
    return actionsButton;
}

- (void)selectActionWithAccessibility:(NSString *)accessibilityId
{
    XCUIElement *menuActionsView = [self waitElementWithAccessibilityId:JMMenuActionsViewAccessibilityId
                                                                timeout:kUITestsBaseTimeout];

    XCUIElement *menuAction = menuActionsView.cells[accessibilityId];
    if (menuAction) {
        [menuAction tap];
    } else {
        XCTFail(@"'%@' button isn't visible", accessibilityId);
    }
}

- (void)openMenuActionsWithControllerAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *actionsButton = [self waitActionsButtonWithControllerAccessibilityId:accessibilityId
                                                                              timeout:kUITestsBaseTimeout];
    [actionsButton tap];
}

@end
