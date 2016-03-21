//
//  JMScheduleManagerTests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/10/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JaspersoftSDK.h"
#import "JMScheduleManager.h"
#import "JMSessionManager.h"
#import "JMConstants.h"

@interface JMScheduleManagerTests : XCTestCase
@property (nonatomic, strong) JMScheduleManager *scheduleManager;
@property (nonatomic, strong) JSScheduleMetadata *testScheduleMetadata;
@property (nonatomic, strong) JSScheduleMetadata *createdScheduleMetadata;
@end

@implementation JMScheduleManagerTests

- (void)setUp {
    [super setUp];

    self.scheduleManager = [JMScheduleManager new];
    self.testScheduleMetadata = [self setupTestScheduleMetadata];
    [self createNewSessionWithExpectation];
    [self createScheduleMetadataWithExpectation];
}

- (void)tearDown {

    [self deleteScheduleMetadataWithExpectation];
    [self cleanSession];
    self.scheduleManager = nil;

    [super tearDown];
}

#pragma mark - Tests Public API
- (void)testThatSchedulesCanBeLoaded
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Load Schedules Expectation"];

    [self.scheduleManager loadSchedulesForResourceLookup:nil
                                              completion:^(NSArray *array, NSError *error) {
                                                  NSLog(@"schedules: %@", array);
                                                  XCTAssertNil(error, @"Load Schedules Error");
                                                  XCTAssertGreaterThan(array.count, 0, @"Should be some schedules");
                                                  [expectation fulfill];
                                              }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
            XCTAssertNil(error);
        }
    }];
}

#pragma mark - Helpers
- (void)createNewSessionWithExpectation
{
    NSString *testProfileURL = @"http://mobiledemo2.jaspersoft.com/jasperserver-pro";
    NSString *testProfileOrganization = kJMDemoServerAlias;
    NSString *testProfileUsername = kJMDemoServerUsername;
    NSString *testProfilePassword = kJMDemoServerPassword;
    JSProfile *testProfile = [[JSProfile alloc] initWithAlias:@"Test Profile"
                                                    serverUrl:testProfileURL
                                                 organization:testProfileOrganization
                                                     username:testProfileUsername
                                                     password:testProfilePassword];

    [[JMSessionManager sharedManager] logout];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Creating Session Expectation"];

    [[JMSessionManager sharedManager] createSessionWithServerProfile:testProfile
                                                          keepLogged:NO
                                                          completion:^(NSError *error) {
                                                              [expectation fulfill];
                                                          }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
            XCTAssertNil(error, @"Timeout error");
        }
    }];
}

- (void)cleanSession
{
    [[JMSessionManager sharedManager] logout];
}

- (JSScheduleMetadata *)setupTestScheduleMetadata
{
    JSScheduleMetadata *scheduleMetadata = [JSScheduleMetadata new];
    scheduleMetadata.label = @"Test Schedule Manager";
    scheduleMetadata.reportUnitURI = @"/public/Samples/Reports/02._Sales_Mix_by_Demographic_Report";
    scheduleMetadata.baseOutputFilename = @"Test_Schedule_Manager";
    scheduleMetadata.folderURI = @"/public/Samples/Reports";
    scheduleMetadata.outputFormats = @[@"PDF"];
    scheduleMetadata.trigger.startDate = [NSDate dateWithTimeIntervalSinceNow:10 * 24 * 60 * 60];

    return scheduleMetadata;
}

- (void)createScheduleMetadataWithExpectation
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Create Schedule Expectation"];

    [self.scheduleManager createJobWithData:self.testScheduleMetadata
                                 completion:^(JSScheduleMetadata *metadata, NSError *error) {
                                     NSLog(@"schedule: %@", metadata);
                                     XCTAssertNil(error, @"Creating Schedule Error");
                                     self.createdScheduleMetadata = metadata;
                                     [expectation fulfill];
                                 }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
            XCTAssertNil(error, @"Timeout error");
        }
    }];
}

- (void)deleteScheduleMetadataWithExpectation
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Delete Schedule Expectation"];

    [self.scheduleManager deleteJobWithJobIdentifier:self.createdScheduleMetadata.jobIdentifier
                                          completion:^(NSError *error) {
                                              XCTAssertNil(error, @"Deleting Schedule Error");
                                              [expectation fulfill];
                                          }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
            XCTAssertNil(error);
        }
    }];
}

@end
