//
// Created by Aleksandr Dakhno on 12/26/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMReportLoaderTests.h"
#import "JMReportLoaderProtocol.h"
#import "JMVisualizeReportLoader.h"

@interface JMVisualizeReportLoaderTests : JMReportLoaderTests
@end

@implementation JMVisualizeReportLoaderTests

#pragma mark - Setups

- (JSProfile *)activeProfile
{
    return [self demoProfile];
}

#pragma mark - Tests

- (void)testRunReportAction
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchSessionExpectation"];
    JMAsyncTask *expectationTask = [JMAsyncTask taskWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start expectation task");
        finishBlock();
        [expectation fulfill];
    }];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self runReportTaskWithReport:[self highchartReportWithoutFilters]
                                                         completion:^(BOOL success, NSError *error) {
                                                             if (!success) {
                                                                 XCTFail(@"Run report wasn't success: %@", error.userInfo);
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

- (void)testRunReportWithSessionExpired
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
    [self.operationQueue addOperation:[self runReportTaskWithReport:[self highchartReportWithoutFilters]
                                                         completion:^(BOOL success, NSError *error) {
                                                             NSLog(@"Error: %@", error);
                                                             if (success) {
                                                                 XCTFail(@"Report should not be run");
                                                             }
                                                             if (error.code != JSReportLoaderErrorTypeSessionDidRestore) {
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

- (void)testNavigationOnPage
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchSessionExpectation"];
    JMAsyncTask *expectationTask = [JMAsyncTask taskWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start expectation task");
        finishBlock();
        [expectation fulfill];
    }];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self runReportTaskWithReport:[self multipageReportWithoutFilters]
                                                         completion:^(BOOL success, NSError *error) {
                                                             if (!success) {
                                                                 XCTFail(@"Run report wasn't success: %@", error.userInfo);
                                                             }
                                                         }]];
    // TODO: consider add a listener about changing multipage status 
    [self.operationQueue addOperation:[self navigateToTaskWithPage:2
                                                        completion:^(BOOL success, NSError *error) {
                                                            if (!success) {
                                                                XCTFail(@"Navigate to page wasn't success: %@", error.userInfo);
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

- (void)testRefreshReportAction
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchSessionExpectation"];
    JMAsyncTask *expectationTask = [JMAsyncTask taskWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start expectation task");
        finishBlock();
        [expectation fulfill];
    }];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self runReportTaskWithReport:[self highchartReportWithoutFilters]
                                                         completion:^(BOOL success, NSError *error) {
                                                             if (!success) {
                                                                 XCTFail(@"Run report wasn't success: %@", error.userInfo);
                                                             }
                                                         }]];
    [self.operationQueue addOperation:[self refreshReportTaskWithCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            XCTFail(@"Refresh report wasn't success: %@", error.userInfo);
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

- (void)testRefreshReportActionAfterSessionExpired
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchSessionExpectation"];
    JMAsyncTask *expectationTask = [JMAsyncTask taskWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start expectation task");
        finishBlock();
        [expectation fulfill];
    }];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self runReportTaskWithReport:[self highchartReportWithoutFilters]
                                                         completion:^(BOOL success, NSError *error) {
                                                             if (!success) {
                                                                 XCTFail(@"Run report wasn't success: %@", error.userInfo);
                                                             }
                                                         }]];
    [self.operationQueue addOperation:[self obsoleteSessionTask]];
    [self.operationQueue addOperation:[self refreshReportTaskWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"Error: %@", error);
        if (success) {
            XCTFail(@"Report should not be refreshed");
        }
        if (error.code != JSReportLoaderErrorTypeSessionDidRestore) {
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

#pragma mark - Tasks

- (NSOperation *)prepareWebEnvironmentTask
{
    JMAsyncTask *prepareWebEnvironmentTask = [[JMAsyncTask alloc] initWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start preparing web environment task");
        self.webEnvironment = [self.webManager reusableWebEnvironmentWithId:@"JMReportViewerVisualizeWebEnvironmentIdentifier"
                                                                   flowType:JMResourceFlowTypeVIZ];
        self.loader = [JMVisualizeReportLoader loaderWithRestClient:self.testRestClient
                                                     webEnvironment:self.webEnvironment];
        finishBlock();
    }];
    return prepareWebEnvironmentTask;
}

@end
