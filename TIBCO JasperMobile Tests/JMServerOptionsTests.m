//
//  JMServerOptionsTests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 12/2/14.
//  Copyright (c) 2014 TIBCO JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "JMServerOptions.h"
#import "JMServerProfile.h"

@interface JMServerOptionsTests : XCTestCase
@property (strong, nonatomic) JMServerProfile *serverProfile;
@end

@implementation JMServerOptionsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.serverProfile = [JMServerProfile new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTest {
    // TODO: create tests
    //XCTAssert(self.serverProfile.alias, @"");
}

@end
