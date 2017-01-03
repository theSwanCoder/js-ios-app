//
// Created by Aleksandr Dakhno on 12/29/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

@import XCTest;
#import "JaspersoftSDK.h"
#import "JMAsyncTask.h"

@protocol JMReportLoaderProtocol;

typedef void(^JMTestBooleanCompletion)(BOOL, NSError *__nullable);

@interface JMSessionManager(Tests)
- (void)updateRestClientWithClient:(JSRESTBase *__nonnull)restClient;
@end

@implementation JMSessionManager(Tests)

- (void) saveActiveSessionIfNeeded:(id __nonnull)notification
{
    NSLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
}

@end

@interface JMResourceLoaderBaseTests : XCTestCase
@property (nonatomic, strong, nullable) NSOperationQueue *operationQueue;
@property (nonatomic, strong, nullable) JMWebViewManager *webManager;
@property (nonatomic, strong, nullable) JMWebEnvironment *webEnvironment;
@property (nonatomic, strong, nullable) JSRESTBase *testRestClient;

- (JSProfile *__nonnull)activeProfile;

- (JSProfile *__nonnull)demoProfile;
- (JSProfile *__nonnull)trunkPROProfile;
- (JSProfile *__nonnull)trunkCEProfile;

- (NSOperation * __nonnull)authorizeTask;
- (NSOperation * __nonnull)obsoleteSessionTask;
- (NSOperation * __nonnull)prepareWebEnvironmentTask;
@end