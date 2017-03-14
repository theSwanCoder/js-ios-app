/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMDashboardLoaderTests.h"
#import "JMDashboardLoader.h"
#import "JMVisDashboardLoader.h"
#import "JMDashboard.h"
#import "JMResource.h"


@implementation JMDashboardLoaderTests

#pragma mark - Setups

- (JSProfile *)activeProfile
{
    return [self trunkPROProfile];
}

#pragma mark - Tests

- (void)testRunDashboardAction
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchSessionExpectation"];
    JMAsyncTask *expectationTask = [JMAsyncTask taskWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start expectation task");
        finishBlock();
        [expectation fulfill];
    }];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self runDashboardTaskWithReport:[self sampleDashboard]
                                                            completion:^(BOOL success, NSError *error) {
                                                                if (!success) {
                                                                    XCTFail(@"Run dashboard wasn't success: %@", error.userInfo);
                                                                }
                                                            }]];
    [self.operationQueue addOperation:expectationTask];

    [self waitForExpectationsWithTimeout:120.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
            XCTAssertNil(error);
        }
    }];
}

- (void)testRunDashboardWithSessionExpired
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchSessionExpectation"];
    JMAsyncTask *expectationTask = [JMAsyncTask taskWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start expectation task");
        finishBlock();
        [expectation fulfill];
    }];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self obsoleteSessionTask]];
    [self.operationQueue addOperation:[self runDashboardTaskWithReport:[self sampleDashboard]
                                                            completion:^(BOOL success, NSError *error) {
                                                                NSLog(@"Error: %@", error);
                                                                if (success) {
                                                                    XCTFail(@"Run dashboard should not be success");
                                                                }
                                                                // TODO: here should be code from visualize
                                                                // JSReportLoaderErrorTypeSessionDidRestore
                                                                // like for reports
                                                                if (error.code != 2) {
                                                                    XCTFail(@"Wrong error code");
                                                                }
                                                            }]];
    [self.operationQueue addOperation:expectationTask];

    [self waitForExpectationsWithTimeout:120.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
            XCTAssertNil(error);
        }
    }];
}

- (void)testReloadDashboardAction
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchSessionExpectation"];
    JMAsyncTask *expectationTask = [JMAsyncTask taskWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start expectation task");
        finishBlock();
        [expectation fulfill];
    }];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self runDashboardTaskWithReport:[self sampleDashboard]
                                                            completion:^(BOOL success, NSError *error) {
                                                                if (!success) {
                                                                    XCTFail(@"Run dashboard wasn't success: %@", error.userInfo);
                                                                    [self reset];
                                                                }
                                                            }]];
    [self.operationQueue addOperation:[self reloadDashboardTaskWithCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            XCTFail(@"Reload dashboard wasn't success: %@", error.userInfo);
        }
    }]];
    [self.operationQueue addOperation:expectationTask];

    [self waitForExpectationsWithTimeout:240.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
            XCTAssertNil(error);
        }
    }];
}

- (void)testRefreshDashboardActionAfterSessionExpired
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchSessionExpectation"];
    JMAsyncTask *expectationTask = [JMAsyncTask taskWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start expectation task");
        finishBlock();
        [expectation fulfill];
    }];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self runDashboardTaskWithReport:[self sampleDashboard]
                                                            completion:^(BOOL success, NSError *error) {
                                                                if (!success) {
                                                                    XCTFail(@"Run dashboard wasn't success: %@", error.userInfo);
                                                                    [self reset];
                                                                }
                                                            }]];
    [self.operationQueue addOperation:[self obsoleteSessionTask]];
    [self.operationQueue addOperation:[self reloadDashboardTaskWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"Error: %@", error);
        if (success) {
            XCTFail(@"Reload dashboard should not be success: %@", error.userInfo);
        }
        // TODO: here should be code from visualize
        // JSReportLoaderErrorTypeSessionDidRestore
        // like for reports
        if (error.code != 2) {
            XCTFail(@"Wrong error code");
        }
    }]];
    [self.operationQueue addOperation:expectationTask];

    [self waitForExpectationsWithTimeout:120.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
            XCTAssertNil(error);
        }
    }];
}

#pragma mark - Sample Dashboards

- (JMDashboard *__nonnull)sampleDashboard
{
    JSResourceLookup *resourceLookup = [JSResourceLookup new];
    resourceLookup.label = @"1. Supermart Dashboard";
    resourceLookup.uri = @"/public/Samples/Dashboards/1._Supermart_Dashboard";
    resourceLookup.resourceDescription = @"Sample containing 5 Dashlets and Filter wiring. One Dashlet is a report with hyperlinks, the other Dashlets are defined as part of the Dashboard.";
    resourceLookup.resourceType = @"dashboard";
    resourceLookup.version = @1;
    resourceLookup.permissionMask = @2;
    JMResource *resource = [JMResource resourceWithResourceLookup:resourceLookup];
    JMDashboard *dashboard = [JMDashboard dashboardWithResource:resource];
    return dashboard;
}


#pragma mark - Tasks

- (NSOperation *)prepareWebEnvironmentTask
{
    JMAsyncTask *prepareWebEnvironmentTask = [[JMAsyncTask alloc] initWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start preparing web environment task");
        self.webEnvironment = [self.webManager reusableWebEnvironmentWithId:@"JMDashboardViewerVisualizeWebEnvironmentIdentifier"
                                                                   flowType:JMResourceFlowTypeVIZ];
        self.loader = [JMVisDashboardLoader loaderWithRESTClient:self.testRestClient
                                                  webEnvironment:self.webEnvironment];
        finishBlock();
    }];
    return prepareWebEnvironmentTask;
}

- (NSOperation * __nonnull)runDashboardTaskWithReport:(JMDashboard *)dashboard
                                           completion:(JMTestBooleanCompletion __nonnull)completion;
{
    JMAsyncTask *runDashboardTask = [[JMAsyncTask alloc] initWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start run dashboard task");
        [self.loader runDashboard:dashboard
                       completion:^(BOOL success, NSError *error) {
                           finishBlock();
                           completion(success, error);
                       }];
    }];
    return runDashboardTask;
}

- (NSOperation *)reloadDashboardTaskWithCompletion:(JMTestBooleanCompletion __nonnull)completion
{
    JMAsyncTask *refreshReportTask = [[JMAsyncTask alloc] initWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start reload dashboard task");
        [self.loader reloadWithCompletion:^(BOOL success, NSError *error) {
            finishBlock();
            completion(success, error);
        }];
    }];
    return refreshReportTask;
}

@end
