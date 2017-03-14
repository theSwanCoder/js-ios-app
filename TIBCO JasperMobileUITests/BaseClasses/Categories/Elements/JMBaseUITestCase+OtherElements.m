/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

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
