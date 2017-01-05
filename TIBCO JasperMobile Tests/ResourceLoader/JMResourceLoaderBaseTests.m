//
// Created by Aleksandr Dakhno on 12/29/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMResourceLoaderBaseTests.h"

@interface JMResourceLoaderBaseTests()
@property (nonatomic, strong) JMSessionManager *sessionManager;
@end

@implementation JMResourceLoaderBaseTests

#pragma mark - Setup

- (void)setUp
{
    [super setUp];

    self.operationQueue = [NSOperationQueue mainQueue];

    self.webManager = [JMWebViewManager new];
    // TODO: Do we need separate tests on different JRS (trunk PRO, trunk CE) or change them if need
    self.testRestClient = [[JSRESTBase alloc] initWithServerProfile:[self activeProfile]
                                                         keepLogged:YES];
    self.sessionManager = [JMSessionManager sharedManager];
    [self.sessionManager updateRestClientWithClient:self.testRestClient];
}

- (void)tearDown
{
    [self.testRestClient deleteCookies];
    self.testRestClient = nil;
    [self.operationQueue cancelAllOperations];
    self.operationQueue = nil;
    self.webEnvironment = nil;
    self.webManager = nil;
    self.sessionManager = nil;

    [super tearDown];
}

- (JSProfile *)activeProfile
{
    return [self demoProfile];
}

#pragma mark - Profiles

- (JSProfile *)demoProfile
{
    JSProfile *profile = [[JSProfile alloc] initWithAlias:@"Test Profile Demo"
                                                serverUrl:@"https://mobiledemo.jaspersoft.com/jasperserver-pro"
                                             organization:nil
                                                 username:@"phoneuser"
                                                 password:@"phoneuser"];
    return profile;
}

- (JSProfile *)trunkPROProfile
{
    JSProfile *profile = [[JSProfile alloc] initWithAlias:@"Test Profile Trunk PRO"
                                                serverUrl:@"http://build-master.jaspersoft.com:5980/jrs-pro-trunk"
                                             organization:nil
                                                 username:@"superuser"
                                                 password:@"superuser"];
    return profile;
}

- (JSProfile *)trunkCEProfile
{
    JSProfile *profile = [[JSProfile alloc] initWithAlias:@"Test Profile Trunk CE"
                                                serverUrl:@"http://build-master.jaspersoft.com:6080/jrs-ce-trunk-ce"
                                             organization:nil
                                                 username:@"jasperadmin"
                                                 password:@"jasperadmin"];
    return profile;
}

- (JSProfile *)localPRO630Profile
{
    JSProfile *profile = [[JSProfile alloc] initWithAlias:@"Test Profile Local 6.3.0 Pro"
                                                serverUrl:@"http://192.168.88.55:8090/jasperserver-pro-630"
                                             organization:nil
                                                 username:@"superuser"
                                                 password:@"superuser"];
    return profile;
}

#pragma mark - Helpers

- (NSOperation *)authorizeTask
{
    JMAsyncTask *authorizeTask = [[JMAsyncTask alloc] initWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start authorize task");
        [self.testRestClient verifyIsSessionAuthorizedWithCompletion:^(JSOperationResult * _Nullable result) {
            NSLog(@"Result: %@", result);
            finishBlock();
        }];
    }];
    return authorizeTask;
}

- (NSOperation *)obsoleteSessionTask
{
    JMAsyncTask *authorizeTask = [[JMAsyncTask alloc] initWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start obsolete session task");
        [self.sessionManager obsoleteSession];
        finishBlock();
    }];
    return authorizeTask;
}

- (NSOperation *)prepareWebEnvironmentTask
{
    @throw [NSException exceptionWithName:@"Not implemented"
                                   reason:@"Should be implemented in child"
                                 userInfo:nil];
}

@end