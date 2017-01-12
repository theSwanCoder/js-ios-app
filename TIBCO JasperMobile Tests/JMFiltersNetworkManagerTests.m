//
// Created by Aleksandr Dakhno on 7/30/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMFiltersNetworkManagerTests.h"

NSString *const kJMFiltersNetworkManagerDemoServerURL = @"https://mobiledemo.jaspersoft.com/jasperserver-pro";
NSString *const kJMFiltersNetworkManagerDemoServerOrganization = @"";
NSString *const kJMFiltersNetworkManagerDemoAccountName = @"phoneuser";
NSString *const kJMFiltersNetworkManagerDemoAccountPassword = @"phoneuser";
NSString *const kJMFiltersNetworkManagerTestReportWithoutFilters_URI = @"/public/Samples/Reports/02._Sales_Mix_by_Demographic_Report";
NSString *const kJMFiltersNetworkManagerTestReportWithFilters_URI = @"/public/Samples/Reports/04._Product_Results_by_Store_Type_Report";
NSString *const kJMFiltersNetworkManagerTestReportWithoutReportOptions_URI = @"/public/Samples/Reports/04._Product_Results_by_Store_Type_Report";
// TODO: add with report options

@interface JMFiltersNetworkManagerTests()
@property (strong, nonatomic) JSRESTBase *testRestClient;
@end

@implementation JMFiltersNetworkManagerTests

- (void)setUp
{
    [super setUp];

    [self addTestRestClient];    
}

- (void)tearDown
{
    [self removeTestRestClient];

    [super tearDown];
}

#pragma mark - Tests

- (void)testThatManagerCanGetListOfFilters
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get list of filters expectation"];
    
    [self.testRestClient verifyIsSessionAuthorizedWithCompletion:^(JSOperationResult * _Nullable result) {
        JMFiltersNetworkManager *networkManager = [JMFiltersNetworkManager managerWithRestClient:self.testRestClient];
        [networkManager loadInputControlsWithResourceURI:kJMFiltersNetworkManagerTestReportWithFilters_URI
                                              completion:^(NSArray *inputControls, NSError *error) {
                                                  [expectation fulfill];
                                                  if (error) {
                                                      XCTFail(@"Error of fetching report's filters");
                                                  } else {
                                                      XCTAssert(inputControls.count > 0, @"The test report should have some filters");
                                                  }
                                              }];    
    }];    
    [self waitForExpectationsWithTimeout:120.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
            XCTAssertNil(error);
        }
    }];
}

- (void)testThatManagerCanGetEmptyListOfFilters
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get list of filters expectation"];
    
    [self.testRestClient verifyIsSessionAuthorizedWithCompletion:^(JSOperationResult * _Nullable result) {
        JMFiltersNetworkManager *networkManager = [JMFiltersNetworkManager managerWithRestClient:self.testRestClient];
        [networkManager loadInputControlsWithResourceURI:kJMFiltersNetworkManagerTestReportWithoutFilters_URI
                                              completion:^(NSArray *inputControls, NSError *error) {
                                                  [expectation fulfill];
                                                  if (error) {
                                                      XCTFail(@"Error of fetching report's filters");
                                                  } else {
                                                      XCTAssert(inputControls.count == 0, @"The test report should not have any filters");
                                                  }
                                              }];    
    }];    
    [self waitForExpectationsWithTimeout:120.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
            XCTAssertNil(error);
        }
    }];
}

- (void)testThatManagerCanGetEmptyListOfReportOptions
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get list of report options expectation"];
    
    [self.testRestClient verifyIsSessionAuthorizedWithCompletion:^(JSOperationResult * _Nullable result) {
        JMFiltersNetworkManager *networkManager = [JMFiltersNetworkManager managerWithRestClient:self.testRestClient];
        [networkManager loadReportOptionsWithResourceURI:kJMFiltersNetworkManagerTestReportWithoutReportOptions_URI completion:^(NSArray * _Nullable reportOptions, NSError * _Nullable error) {
            [expectation fulfill];
            if (error) {
                XCTFail(@"Error of fetching report's options");
            } else {
                XCTAssert(reportOptions.count == 0, @"The test report should not have any options");
            }
        }];    
    }];    
    [self waitForExpectationsWithTimeout:120.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
            XCTAssertNil(error);
        }
    }];
}

#pragma mark - Helpers

- (void)addTestRestClient
{
    JSProfile *demoProfile = [self createDemoProfile];
    self.testRestClient = [self createRestClientWithServerProfile:demoProfile];
}

- (JSProfile *)createDemoProfile
{
    JSUserProfile *demoProfile = [[JSUserProfile alloc] initWithAlias:@"Demo Profile"
                                                            serverUrl:kJMFiltersNetworkManagerDemoServerURL
                                                         organization:kJMFiltersNetworkManagerDemoServerOrganization
                                                             username:kJMFiltersNetworkManagerDemoAccountName
                                                             password:kJMFiltersNetworkManagerDemoAccountPassword];
    demoProfile.keepSession = YES;
    return demoProfile;
}

- (JSRESTBase *)createRestClientWithServerProfile:(JSProfile *)profile
{
    JSRESTBase *restClient = [[JSRESTBase alloc] initWithServerProfile:profile];
    return restClient;
}

- (void)removeTestRestClient
{
    NSHTTPCookieStorage *sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in sharedCookieStorage.cookies) {
        [sharedCookieStorage deleteCookie:cookie];
    }
    self.testRestClient = nil;
}

@end
