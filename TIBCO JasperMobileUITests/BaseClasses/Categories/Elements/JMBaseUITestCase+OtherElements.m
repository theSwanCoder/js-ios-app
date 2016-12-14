//
// Created by Aleksandr Dakhno on 12/10/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+OtherElements.h"
#import "JMBaseUITestCase+Helpers.h"


@implementation JMBaseUITestCase (OtherElements)

- (void)verifyThatElementWithIdExist:(NSString *)elementId
{
    XCUIElement *element = [self waitElementMatchingType:XCUIElementTypeOther
                                              identifier:elementId
                                                 timeout:kUITestsBaseTimeout];
    if (!element.exists) {
        XCTFail(@"Element with id: %@, wasn't found", elementId);
    }
}

@end