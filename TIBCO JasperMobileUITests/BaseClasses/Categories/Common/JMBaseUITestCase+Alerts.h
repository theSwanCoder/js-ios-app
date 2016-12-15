//
// Created by Aleksandr Dakhno on 12/15/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Alerts)
- (XCUIElement *)findAlertWithTitle:(NSString *)title;
- (XCUIElement *)waitAlertWithTitle:(NSString *)title timeout:(NSTimeInterval)timeout;
@end