//
// Created by Aleksandr Dakhno on 9/7/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Buttons.h"
#import "XCUIElement+Tappable.h"


@implementation JMBaseUITestCase (ActionsMenu)

- (void)openMenuActions
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self openMenuActionsOnNavBarWithLabel:nil];
}

- (void)openMenuActionsOnNavBarWithLabel:(NSString *)label
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *actionsButton = [self waitActionsButtonOnNavBarWithLabel:label
                                                                  timeout:kUITestsElementAvailableTimeout];
    [actionsButton tapByWaitingHittable];
}

- (void)selectActionWithName:(NSString *)actionName
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *menuActionsView = [self waitElementMatchingType:XCUIElementTypeOther
                                                      identifier:@"JMMenuActionsViewAccessibilityId"
                                                         timeout:kUITestsElementAvailableTimeout];
    if (!menuActionsView.exists) {
        XCTFail(@"Menu actions wasn't found");
    }
    XCUIElement *saveButton = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                       text:actionName
                                              parentElement:menuActionsView
                                                    timeout:kUITestsElementAvailableTimeout];
    if (saveButton.exists) {
        [saveButton tapByWaitingHittable];
    } else {
        XCTFail(@"'%@' button isn't visible", actionName);
    }
}

- (BOOL)isShareButtonExists
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *actionsButton = [self findActionsButton];
    return actionsButton.exists;
}

- (XCUIElement *)findActionsButton
{
    return [self findActionsButtonOnNavBarWithLabel:nil];
}

- (XCUIElement *)findActionsButtonOnNavBarWithLabel:(NSString *)label
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *navBar;
    if (label) {
        navBar = [self findNavigationBarWithLabel:label];
    }
    XCUIElement *actionsButton = [self buttonWithId:@"Share"
                                      parentElement:navBar
                                        shouldCheck:YES];
    return actionsButton;
}

- (XCUIElement *)waitActionsButtonWithTimeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [self waitActionsButtonOnNavBarWithLabel:nil
                                            timeout:timeout];
}

- (XCUIElement *)waitActionsButtonOnNavBarWithLabel:(NSString *)label
                                            timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *navBar;
    if (label) {
        navBar = [self waitNavigationBarWithLabel:label
                                          timeout:timeout];
    }

    XCUIElement *actionsButton = [self buttonWithId:@"Share"
                                      parentElement:navBar
                                        shouldCheck:YES];
    return actionsButton;
}

@end