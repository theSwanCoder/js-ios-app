//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Resource.h"
#import "JMBaseUITestCase+Helpers.h"


@implementation JMBaseUITestCase (Resource)

- (void)openInfoPageForResource:(XCUIElement *)resource
{
    XCUIElement *infoButton = [self waitButtonWithAccessibilityId:@"More Info"
                                                    parentElement:resource
                                                          timeout:kUITestsBaseTimeout];
    [infoButton tap];
}

- (void)closeInfoPage
{
    [self tryBackToPreviousPage];
}

- (void)verifyInfoPageOnScreenForPageWithAccessibilityId:(NSString *)accessibilityId
{
    [self waitElementWithAccessibilityId:accessibilityId
                                 timeout:kUITestsBaseTimeout];
}

@end
