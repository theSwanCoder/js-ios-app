/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMResourceLoaderBaseTests.h"

@interface JMResourceLoaderBaseTests()
@property (nonatomic, strong) JMSessionManager *sessionManager;
@end

@implementation JMResourceLoaderBaseTests

#pragma mark - Setup

- (void)setUp
{
    [super setUp];

    NSLog(@"Super: start setUp");
    self.operationQueue = [NSOperationQueue mainQueue];
    NSLog(@"Super: self.operationQueue: %@", self.operationQueue);
    self.operationQueue.maxConcurrentOperationCount = 1;

    self.webManager = [JMWebViewManager new];
    // TODO: Do we need separate tests on different JRS (trunk PRO, trunk CE) or change them if need
    self.testRestClient = [[JSRESTBase alloc] initWithServerProfile:[self activeProfile]];
    self.sessionManager = [JMSessionManager sharedManager];
    [self.sessionManager updateRestClientWithClient:self.testRestClient];
    NSLog(@"Super: end setUp");
}

- (void)tearDown
{
    NSLog(@"Super: start tearDown");
    [self reset];
    NSLog(@"Super: end tearDown");

    [super tearDown];
}

- (JSProfile *)activeProfile
{
    return [self demoProfile];
}

#pragma mark - Profiles

- (JSProfile *)demoProfile
{
    JSUserProfile *profile = [[JSUserProfile alloc] initWithAlias:@"Test Profile Demo"
                                                        serverUrl:@"https://mobiledemo.jaspersoft.com/jasperserver-pro"
                                                     organization:nil
                                                         username:@"phoneuser"
                                                         password:@"phoneuser"];
    profile.keepSession = YES;
    return profile;
}

- (JSProfile *)trunkPROProfile
{
    JSUserProfile *profile = [[JSUserProfile alloc] initWithAlias:@"Test Profile Trunk PRO"
                                                        serverUrl:@"http://build-master.jaspersoft.com:5980/jrs-pro-trunk"
                                                     organization:nil
                                                         username:@"superuser"
                                                         password:@"superuser"];
    profile.keepSession = YES;
    return profile;
}

- (JSProfile *)trunkCEProfile
{
    JSUserProfile *profile = [[JSUserProfile alloc] initWithAlias:@"Test Profile Trunk CE"
                                                        serverUrl:@"http://build-master.jaspersoft.com:6080/jrs-ce-trunk-ce"
                                                     organization:nil
                                                         username:@"jasperadmin"
                                                         password:@"jasperadmin"];
    profile.keepSession = YES;
    return profile;
}

- (JSProfile *)localPRO630Profile
{
    JSUserProfile *profile = [[JSUserProfile alloc] initWithAlias:@"Test Profile Local 6.3.0 Pro"
                                                        serverUrl:@"http://192.168.88.55:8090/jasperserver-pro-630"
                                                     organization:nil
                                                         username:@"superuser"
                                                         password:@"superuser"];
    profile.keepSession = YES;
    return profile;
}

#pragma mark - Helpers

- (NSOperation *)authorizeTask
{
    JMAsyncTask *authorizeTask = [[JMAsyncTask alloc] initWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start authorize task");
        [self.testRestClient verifyIsSessionAuthorizedWithCompletion:^(JSOperationResult * _Nullable result) {
            NSLog(@"Result: %@", result);
            NSLog(@"Finish authorize task");
            finishBlock();
        }];
    }];
    authorizeTask.taskDescription = [NSString stringWithFormat:@"authorizeTask in [%@ %@]", self.class.description, NSStringFromSelector(_cmd)];
    return authorizeTask;
}

- (NSOperation *)obsoleteSessionTask
{
    JMAsyncTask *obsoleteTask = [[JMAsyncTask alloc] initWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start obsolete session task");
        [self.sessionManager obsoleteSession];
        NSLog(@"End obsolete session task");
        finishBlock();
    }];
    obsoleteTask.taskDescription = [NSString stringWithFormat:@"obsoleteTask in [%@ %@]", self.class.description, NSStringFromSelector(_cmd)];
    return obsoleteTask;
}

- (NSOperation *)prepareWebEnvironmentTask
{
    @throw [NSException exceptionWithName:@"Not implemented"
                                   reason:@"Should be implemented in child"
                                 userInfo:nil];
}

- (void)reset
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.testRestClient deleteCookies];
    self.testRestClient = nil;
    NSLog(@"BEFORE self.operationQueue: %@", self.operationQueue);
    NSLog(@"BEFORE operations: %@", self.operationQueue.operations);
    // Because of we are using a main queue to execute operations, for canceling we need use this approach
    [self.operationQueue.operations makeObjectsPerformSelector:@selector(cancel)];
    NSLog(@"AFTER operations: %@", self.operationQueue.operations);
    //self.operationQueue = nil;
    self.webEnvironment = nil;
    self.webManager = nil;
    self.sessionManager = nil;
}

@end
