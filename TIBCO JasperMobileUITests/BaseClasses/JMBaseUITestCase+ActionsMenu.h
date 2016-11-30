//
// Created by Aleksandr Dakhno on 9/7/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (ActionsMenu)
- (BOOL)isShareButtonExists;
- (XCUIElement *)findActionsButton;
- (XCUIElement *)findActionsButtonOnNavBarWithLabel:(NSString *)label;
- (XCUIElement *)waitActionsButtonWithTimeout:(NSTimeInterval)timeout;
- (XCUIElement *)waitActionsButtonOnNavBarWithLabel:(NSString *)label
                                            timeout:(NSTimeInterval)timeout;

- (void)openMenuActions;
- (void)selectActionWithName:(NSString *)actionName;
- (void)openMenuActionsOnNavBarWithLabel:(NSString *)label;
@end