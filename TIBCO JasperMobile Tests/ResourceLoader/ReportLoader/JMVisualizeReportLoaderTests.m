/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMReportLoaderTests.h"
#import "JMReportLoaderProtocol.h"
#import "JMVisualizeReportLoader.h"

@interface JMVisualizeReportLoaderTests : JMReportLoaderTests
@end

@implementation JMVisualizeReportLoaderTests

#pragma mark - Setups

- (JSProfile *)activeProfile
{
    return [self trunkPROProfile];
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
    expectationTask.taskDescription = [NSString stringWithFormat:@"expectationTask in [%@ %@]", self.class.description, NSStringFromSelector(_cmd)];

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
    expectationTask.taskDescription = [NSString stringWithFormat:@"expectationTask in [%@ %@]", self.class.description, NSStringFromSelector(_cmd)];

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
    expectationTask.taskDescription = [NSString stringWithFormat:@"expectationTask in [%@ %@]", self.class.description, NSStringFromSelector(_cmd)];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self runReportTaskWithReport:[self multipageReportWithoutFilters]
                                                         completion:^(BOOL success, NSError *error) {
                                                             if (!success) {
                                                                 XCTFail(@"Run report wasn't success: %@", error.userInfo);
                                                                 [self reset];
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
    expectationTask.taskDescription = [NSString stringWithFormat:@"expectationTask in [%@ %@]", self.class.description, NSStringFromSelector(_cmd)];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self runReportTaskWithReport:[self highchartReportWithoutFilters]
                                                         completion:^(BOOL success, NSError *error) {
                                                             if (!success) {
                                                                 XCTFail(@"Run report wasn't success: %@", error.userInfo);
                                                                 [self reset];
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
    expectationTask.taskDescription = [NSString stringWithFormat:@"expectationTask in [%@ %@]", self.class.description, NSStringFromSelector(_cmd)];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self runReportTaskWithReport:[self highchartReportWithoutFilters]
                                                         completion:^(BOOL success, NSError *error) {
                                                             if (!success) {
                                                                 XCTFail(@"Run report wasn't success: %@", error.userInfo);
                                                                 [self reset];
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
    prepareWebEnvironmentTask.taskDescription = [NSString stringWithFormat:@"prepareWebEnvironmentTask in [%@ %@]", self.class.description, NSStringFromSelector(_cmd)];
    return prepareWebEnvironmentTask;
}

@end
