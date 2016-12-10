//
// Created by Aleksandr Dakhno on 12/10/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Buttons)
- (void)tapButtonWithId:(NSString *)buttonId parentElement:(XCUIElement *)parentElement;
- (void)tapButtonWithText:(NSString *)text parentElement:(XCUIElement *)parentElement;
@end
