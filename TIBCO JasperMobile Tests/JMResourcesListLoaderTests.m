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

@interface TestResource : NSObject
@property (nonatomic, strong) NSString *label;
@end

@implementation TestResource

@end


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

#pragma mark - Setup Instance
- (void)testInstanceNotNil {
    XCTAssertNotNil(self.resourceLoader, @"Instance should not be nil");
}

#pragma mark - Test Loading process
- (void)testThatLoaderCanStartLoadingProcess
{
    self.completionExpectation = [self expectationWithDescription:@"Start loading process"];
    [self.resourceLoader setNeedsUpdate];
    [self.resourceLoader updateIfNeeded];
    
    // time of expectation selected 2.0 sec
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testThatLoaderCleanedUpOldResourcesfBeforeStartLoadingProcess
{
    // add object as resource
    [self.resourceLoader addResourcesWithResource:[TestResource new]];
    
    // verify resource is saved by loader
    XCTAssertEqual(self.resourceLoader.resourceCount, 1, @"Count of resources should be equal 1");
    
    [self.resourceLoader setNeedsUpdate];
    [self.resourceLoader updateIfNeeded];
    
    // verify loader is cleaned
    XCTAssertEqual(self.resourceLoader.resourceCount, 0, @"Count of resources should be equal 0");
}

- (void)testThatLoaderCanEndLoadingProcess
{
    self.completionExpectation = [self expectationWithDescription:@"End loading process"];
    [self.resourceLoader setNeedsUpdate];
    [self.resourceLoader updateIfNeeded];
    
    // time of expectation selected 2.0 sec
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

#pragma mark - Test helper methods
- (void)testThatLoaderCanAddOneResource
{
    // verify loader doesn't containt resources
    XCTAssertEqual(self.resourceLoader.resourceCount, 0, @"Count of resources should be equal 0");
    
    // add one resource
    TestResource *resource = [TestResource new];
    [self.resourceLoader addResourcesWithResource:resource];
    
    // verify loader contains one resource
    XCTAssertEqual(self.resourceLoader.resourceCount, 1, @"Count of resources should be equal 1");
}

- (void)testThatLoaderCanAddSeveralResources
{
    // verify loader doesn't containt resources
    XCTAssertEqual(self.resourceLoader.resourceCount, 0, @"Count of resources should be equal 0");
    
    // add resources
    NSArray *resources = @[
                           [TestResource new],
                           [TestResource new]
                           ];
    [self.resourceLoader addResourcesWithResources:resources];
    
    // verify loader contains one resource
    XCTAssertEqual(self.resourceLoader.resourceCount, resources.count, @"Count of resources should be equal 2");
}

- (void)testThatLoaderCanSortResources
{
    TestResource *resourceA = [TestResource new];
    resourceA.label = @"A";
    TestResource *resourceB = [TestResource new];
    resourceB.label = @"B";
    
    NSArray *resources = @[
                           resourceB,
                           resourceA
                           ];
    [self.resourceLoader addResourcesWithResources:resources];

    TestResource *firstResource = [self.resourceLoader resourceAtIndex:0];

    // for begin, first object is "B"
    XCTAssertEqualObjects(firstResource.label, @"B");
    
    [self measureBlock:^{
        [self.resourceLoader sortLoadedResourcesUsingComparator:^NSComparisonResult(TestResource *obj1, TestResource *obj2) {
            return [obj1.label compare:obj2.label options:NSCaseInsensitiveSearch];
        }];
    }];
    
    firstResource = [self.resourceLoader resourceAtIndex:0];
    // after sort, first object is "A"
    XCTAssertEqualObjects(firstResource.label, @"A");
}

#pragma mark - Test search
// TODO: how we can test search??? it's server feature


#pragma mark - JMResourcesListLoaderDelegate methods
- (void)resourceListLoaderDidStartLoad:(JMResourcesListLoader *)listLoader
{
    [self.completionExpectation fulfill];
}

- (void)resourceListLoaderDidEndLoad:(JMResourcesListLoader *)listLoader withResources:(NSArray *)resources
{
    [self.completionExpectation fulfill];
}

- (void)resourceListLoaderDidFailed:(JMResourcesListLoader *)listLoader withError:(NSError *)error
{
    
}

@end
