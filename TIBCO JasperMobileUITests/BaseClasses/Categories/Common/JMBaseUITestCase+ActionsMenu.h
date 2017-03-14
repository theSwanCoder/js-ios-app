/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

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
