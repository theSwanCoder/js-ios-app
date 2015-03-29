//
//  JMResourcesListLoaderTests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 3/29/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "JMResourcesListLoader.h"

@interface JMResourcesListLoaderTests : XCTestCase <JMResourcesListLoaderDelegate>
@property (nonatomic, strong) JMResourcesListLoader *resourceLoader;
@property (nonatomic, strong) XCTestExpectation *completionExpectation;
@end

@implementation JMResourcesListLoaderTests

- (void)setUp {
    [super setUp];

    self.resourceLoader = [JMResourcesListLoader new];
    self.resourceLoader.delegate = self;
}

- (void)tearDown {
    self.resourceLoader.delegate = nil;
    self.resourceLoader = nil;
    
    self.completionExpectation = nil;
    
    [super tearDown];
}

- (void)testInstanceNotNil {
    XCTAssertNotNil(self.resourceLoader, @"Instance should not be nil");
}

- (void)testThatLoaderStartLoadingProcess
{
    self.completionExpectation = [self expectationWithDescription:@"Start loading process"];
    [self.resourceLoader setNeedsUpdate];
    [self.resourceLoader updateIfNeeded];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testThatLoaderCleanedUpOldResourcesfBeforeStartLoadingProcess
{
    // add object as resource
    [self.resourceLoader addResourcesWithResource:[NSObject new]];
    
    // verify resource is saved by loader
    XCTAssertEqual(self.resourceLoader.resourceCount, 1, @"Count of resources should be equal 1");
    
    [self.resourceLoader setNeedsUpdate];
    [self.resourceLoader updateIfNeeded];
    
    // verify loader is cleaned
    XCTAssertEqual(self.resourceLoader.resourceCount, 0, @"Count of resources should be equal 0");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - JMResourcesListLoaderDelegate methods
- (void)resourceListLoaderDidStartLoad:(JMResourcesListLoader *)listLoader
{
    [self.completionExpectation fulfill];
}

- (void)resourceListLoaderDidEndLoad:(JMResourcesListLoader *)listLoader withResources:(NSArray *)resources
{
    
}

- (void)resourceListLoaderDidFailed:(JMResourcesListLoader *)listLoader withError:(NSError *)error
{
    
}

@end
