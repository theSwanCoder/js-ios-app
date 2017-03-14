/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMReportLoaderTests.h"
#import "JMRestReportLoader.h"

@interface JMRESTReportLoaderTests : JMReportLoaderTests
@end

@implementation JMRESTReportLoaderTests

#pragma mark - Setups

- (JSProfile *)activeProfile
{
    return [self trunkCEProfile];
}

#pragma mark - Tests

- (void)testRunReportAction
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testRunReportAction"];
    JMAsyncTask *expectationTask = [JMAsyncTask taskWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start expectation task");
        [expectation fulfill];
        finishBlock();
    }];
    expectationTask.taskDescription = [NSString stringWithFormat:@"expectationTask in [%@ %@]", self.class.description, NSStringFromSelector(_cmd)];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self runReportTaskWithReport:[self customersReportOnTrunkCE]
                                                         completion:^(BOOL success, NSError *error) {
                                                             NSLog(@"Callback for 'RUN' from %@", NSStringFromSelector(_cmd));
                                                             if (!success) {
                                                                 NSLog(@"Not success 'RUN'");
                                                                 [self reset];
                                                                 [expectation fulfill];
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
    XCTestExpectation *expectation = [self expectationWithDescription:@"testRunReportWithSessionExpired"];
    JMAsyncTask *expectationTask = [JMAsyncTask taskWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start expectation task");
        [expectation fulfill];
        finishBlock();
    }];
    expectationTask.taskDescription = [NSString stringWithFormat:@"expectationTask in [%@ %@]", self.class.description, NSStringFromSelector(_cmd)];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self obsoleteSessionTask]];
    [self.operationQueue addOperation:[self runReportTaskWithReport:[self customersReportOnTrunkCE]
                                                         completion:^(BOOL success, NSError *error) {
                                                             NSLog(@"Callback for 'RUN' from %@", NSStringFromSelector(_cmd));
                                                             NSLog(@"Error: %@", error);
                                                             if (!success) {
                                                                 NSLog(@"Not success 'RUN'");
                                                                 [self reset];
                                                                 [expectation fulfill];
                                                                 XCTFail(@"Report should be run");
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
    XCTestExpectation *expectation = [self expectationWithDescription:@"testRefreshReportAction"];
    JMAsyncTask *expectationTask = [JMAsyncTask taskWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start expectation task");
        [expectation fulfill];
        finishBlock();
    }];
    expectationTask.taskDescription = [NSString stringWithFormat:@"expectationTask in [%@ %@]", self.class.description, NSStringFromSelector(_cmd)];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self runReportTaskWithReport:[self customersReportOnTrunkCE]
                                                         completion:^(BOOL success, NSError *error) {
                                                             NSLog(@"Callback for 'RUN' from %@", NSStringFromSelector(_cmd));
                                                             if (!success) {
                                                                 NSLog(@"Not success 'RUN'");
                                                                 [self reset];
                                                                 [expectation fulfill];
                                                                 XCTFail(@"Run report wasn't success: %@", error.userInfo);
                                                             }
                                                         }]];
    [self.operationQueue addOperation:[self refreshReportTaskWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"Callback for 'REFRESH' from %@", NSStringFromSelector(_cmd));
        if (!success) {
            NSLog(@"Not success 'REFRESH'");
            [self reset];
            [expectation fulfill];
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
    XCTestExpectation *expectation = [self expectationWithDescription:@"testRefreshReportActionAfterSessionExpired"];
    JMAsyncTask *expectationTask = [JMAsyncTask taskWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start expectation task");
        [expectation fulfill];
        finishBlock();
    }];
    expectationTask.taskDescription = [NSString stringWithFormat:@"expectationTask in [%@ %@]", self.class.description, NSStringFromSelector(_cmd)];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self runReportTaskWithReport:[self customersReportOnTrunkCE]
                                                         completion:^(BOOL success, NSError *error) {
                                                             NSLog(@"Callback for 'RUN' from %@", NSStringFromSelector(_cmd));
                                                             if (!success) {
                                                                 [self reset];
                                                                 [expectation fulfill];
                                                                 XCTFail(@"Run report wasn't success: %@", error.userInfo);
                                                             }
                                                         }]];
    [self.operationQueue addOperation:[self obsoleteSessionTask]];
    [self.operationQueue addOperation:[self refreshReportTaskWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"Callback for 'REFRESH' from %@", NSStringFromSelector(_cmd));
        NSLog(@"Error: %@", error);
        if (success) {
            NSLog(@"Success 'REFRESH'");
            [self reset];
            [expectation fulfill];
            XCTFail(@"Report should not be refreshed");
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
    XCTestExpectation *expectation = [self expectationWithDescription:@"testNavigationOnPage"];
    JMAsyncTask *expectationTask = [JMAsyncTask taskWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start expectation task");
        [expectation fulfill];
        finishBlock();
    }];
    expectationTask.taskDescription = [NSString stringWithFormat:@"expectationTask in [%@ %@]", self.class.description, NSStringFromSelector(_cmd)];

    [self.operationQueue addOperation:[self authorizeTask]];
    [self.operationQueue addOperation:[self prepareWebEnvironmentTask]];
    [self.operationQueue addOperation:[self runReportTaskWithReport:[self customersReportOnTrunkCE]
                                                         completion:^(BOOL success, NSError *error) {
                                                             NSLog(@"Callback for 'RUN' from %@", NSStringFromSelector(_cmd));
                                                             if (!success) {
                                                                 NSLog(@"Not success 'RUN'");
                                                                 [self reset];
                                                                 [expectation fulfill];
                                                                 XCTFail(@"Run report wasn't success: %@", error.userInfo);
                                                             }
                                                         }]];
    // TODO: consider add a listener about changing multipage status
    [self.operationQueue addOperation:[self navigateToTaskWithPage:2
                                                        completion:^(BOOL success, NSError *error) {
                                                            NSLog(@"Callback for 'NAVIGATE TO' from %@", NSStringFromSelector(_cmd));
                                                            if (!success) {
                                                                NSLog(@"Not success 'NAVIGATE TO'");
                                                                [self reset];
                                                                [expectation fulfill];
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

#pragma mark - Tasks

- (NSOperation *)prepareWebEnvironmentTask
{
    JMAsyncTask *prepareWebEnvironmentTask = [[JMAsyncTask alloc] initWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start preparing web environment task");
        self.webEnvironment = [self.webManager reusableWebEnvironmentWithId:@"JMReportViewerRESTWebEnvironmentIdentifier"
                                                                   flowType:JMResourceFlowTypeREST];
        self.loader = [JMRestReportLoader loaderWithRestClient:self.testRestClient
                                                webEnvironment:self.webEnvironment];
        NSLog(@"End preparing web environment task");
        finishBlock();
    }];
    prepareWebEnvironmentTask.taskDescription = [NSString stringWithFormat:@"prepareWebEnvironmentTask in [%@ %@]", self.class.description, NSStringFromSelector(_cmd)];
    return prepareWebEnvironmentTask;
}

@end
