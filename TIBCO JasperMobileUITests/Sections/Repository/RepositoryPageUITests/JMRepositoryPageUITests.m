//
//  JMRepositoryPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMRepositoryPageUITests.h"

@implementation JMRepositoryPageUITests

#pragma mark - Setup
- (void)setUp {
    [super setUp];
    
    XCUIElement *loginPageView = self.application.otherElements[@"JMLoginPageAccessibilityId"];
    if (loginPageView.exists) {
        [self loginWithTestProfile];
    }
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Tests
- (void)testThatAlwaysFail
{
    XCTFail(@"Not implemented tests");
}

@end
