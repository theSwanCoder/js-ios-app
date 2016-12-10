//
// Created by Aleksandr Dakhno on 12/10/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+Helpers.h"


@implementation JMBaseUITestCase (Buttons)

- (void)tapButtonWithId:(NSString *)buttonId
          parentElement:(XCUIElement *)parentElement
{
    XCUIElement *button = [self waitElementMatchingType:XCUIElementTypeButton
                                             identifier:buttonId
                                          parentElement:parentElement
                                                timeout:kUITestsBaseTimeout];
    if (button.exists) {
        [button tap];
    } else {
        NSLog(@"All buttons: %@", self.application.buttons.allElementsBoundByAccessibilityElement);
        XCTFail(@"Button with id: %@, wasn't found", buttonId);
    }
}

- (void)tapButtonWithText:(NSString *)text
            parentElement:(XCUIElement *)parentElement
{
    XCUIElement *button = [self waitElementMatchingType:XCUIElementTypeButton
                                                   text:text
                                          parentElement:parentElement
                                                timeout:0]; // It's suggested that element on which button lies have been already found
    if (button.exists) {
        [button tap];
    } else {
        NSLog(@"All buttons: %@", self.application.buttons.allElementsBoundByAccessibilityElement);
        XCTFail(@"Button with text: %@, wasn't found", text);
    }
}

@end