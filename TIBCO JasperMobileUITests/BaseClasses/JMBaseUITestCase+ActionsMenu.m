//
// Created by Aleksandr Dakhno on 9/7/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Helpers.h"


@implementation JMBaseUITestCase (ActionsMenu)

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