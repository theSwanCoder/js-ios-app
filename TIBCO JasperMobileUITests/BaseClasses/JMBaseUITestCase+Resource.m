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

- (void)closeInfoPageWithBackButton
{
    [self tryBackToPreviousPage];
}

- (void)closeInfoPageWithCancelButton
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:nil];
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"Cancel"
                                                      parentElement:navBar
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

- (void)verifyInfoPageOnScreenForPageWithAccessibilityId:(NSString *)accessibilityId
{
    [self waitElementWithAccessibilityId:accessibilityId
                                 timeout:kUITestsBaseTimeout];
}

@end
