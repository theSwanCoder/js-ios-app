//
// Created by Aleksandr Dakhno on 9/7/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (ActionsMenu)
- (BOOL)isActionsButtonExists;
- (XCUIElement *)findActionsButtonWithControllerAccessibilityId:(NSString *)controllerAccessibilityId;
- (XCUIElement *)waitActionsButtonWithControllerAccessibilityId:(NSString *)controllerAccessibilityId
                                                        timeout:(NSTimeInterval)timeout;

- (void)selectActionWithName:(NSString *)actionName;
- (void)openMenuActionsWithControllerAccessibilityId:(NSString *)accessibilityId;
@end
