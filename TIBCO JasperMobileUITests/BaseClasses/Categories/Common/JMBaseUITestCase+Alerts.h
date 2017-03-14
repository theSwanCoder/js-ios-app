/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Alerts)
- (XCUIElement *)findAlertWithTitle:(NSString *)title;
- (XCUIElement *)waitAlertWithTitle:(NSString *)title timeout:(NSTimeInterval)timeout;
- (void)processErrorAlertsIfExistWithTitles:(NSArray *)titles
                                actionBlock:(void(^)(void))actionBlock;
- (void)processErrorAlertIfExistWithTitle:(NSString *)title
                                  message:(NSString *)message
                              actionBlock:(void(^)(void))actionBlock;
@end
