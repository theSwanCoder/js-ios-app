/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMWebEnvironmentUpdateCookiesTask.h"
#import "JMJavascriptRequestExecutor.h"


@interface JMWebEnvironmentUpdateCookiesTask()
@property (nonatomic, strong) JMJavascriptRequestExecutor *requestExecutor;
@property (nonatomic, strong) NSArray <NSHTTPCookie *> *cookies;
@property (nonatomic, strong) JSRESTBase *RESTClient;
@property (nonatomic, copy) void(^completion)(void);
@end

@implementation JMWebEnvironmentUpdateCookiesTask

#pragma mark - Life Cycle

- (instancetype)initWithRESTClient:(JSRESTBase *)RESTClient requestExecutor:(JMJavascriptRequestExecutor *)requestExecutor cookies:(NSArray <NSHTTPCookie *>*)cookies competion:(void(^)(void))completion
{
    self = [super init];
    if (self) {
        NSAssert(RESTClient != nil, @"REST Client is nil");
        NSAssert(requestExecutor != nil, @"Request executor is nil");
        _RESTClient = RESTClient;
        _requestExecutor = requestExecutor;
        _cookies = cookies;
        _completion = [completion copy];
    }
    return self;
}

+ (instancetype)taskWithRESTClient:(JSRESTBase *)RESTClient requestExecutor:(JMJavascriptRequestExecutor *)requestExecutor cookies:(NSArray <NSHTTPCookie *>*)cookies competion:(void(^)(void))completion
{
    return [[self alloc] initWithRESTClient:RESTClient
                            requestExecutor:requestExecutor
                                    cookies:cookies
                                  competion:completion];
}

#pragma mark - Overridden methods NSOperation

- (void)main
{
    if (self.isCancelled) {
        return;
    }
    JMLog(@"%@ - start updating cookies", self);
    __weak __typeof(self) weakSelf = self;
    [self updateCookiesWithCookies:self.cookies completion:^(BOOL success){
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf.isCancelled) {
            // TODO: add sending a canceling error
            return;
        }
        JMLog(@"%@ - end updating cookies", strongSelf);
        strongSelf.state = JMAsyncTaskStateFinished;
        if (strongSelf.completion) {
            strongSelf.completion();
        }
    }];
}

- (void)updateCookiesWithCookies:(NSArray *)cookies completion:(void(^)(BOOL success))completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    __weak __typeof(self) weakSelf = self;
    [self removeCookiesWithCompletion:^(BOOL success) {
        __typeof(self) strongSelf = weakSelf;
        if (success) {
            NSString *cookiesAsString = [strongSelf cookiesAsStringFromCookies:cookies];
            [strongSelf.requestExecutor.webView evaluateJavaScript:cookiesAsString completionHandler:^(id o, NSError *error) {
                JMLog(@"setting cookies finished");
                if (error) {
                    // TODO: how handle this case?
                    JMLog(@"error of updating cookies: %@", error);
                    completion(NO);
                } else {
                    JMLog(@"cookies: %@", o);
                    completion(YES);
                }
            }];
        } else {
            // TODO: how handle this case?
        }
    }];
}


- (void)removeCookiesWithCompletion:(void(^)(BOOL success))completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    if ([JMUtils isSystemVersionEqualOrUp9]) {
        [self removeCookiesForNewVersionWithCompletion:completion];
    } else {
        [self removeCookiesForOldVersionWithCompletion:completion];
    }
}

- (void)removeCookiesForNewVersionWithCompletion:(void(^)(BOOL success))completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSSet *dataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    WKWebsiteDataStore *websiteDataStore = self.requestExecutor.webView.configuration.websiteDataStore;
    [websiteDataStore fetchDataRecordsOfTypes:dataTypes
                            completionHandler:^(NSArray<WKWebsiteDataRecord *> *records) {
                                for (WKWebsiteDataRecord *record in records) {
                                    NSURL *serverURL = [NSURL URLWithString:self.RESTClient.serverProfile.serverUrl];
                                    if ([record.displayName containsString:serverURL.host]) {
                                        [websiteDataStore removeDataOfTypes:record.dataTypes
                                                             forDataRecords:@[record]
                                                          completionHandler:^{
                                                              JMLog(@"record (%@) removed successfully", record);
                                                          }];
                                    }
                                }
                                if (completion) {
                                    completion(YES);
                                }
                            }];
}

- (void)removeCookiesForOldVersionWithCompletion:(void(^)(BOOL success))completion
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
    NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cookiesFolderPath error:&error];
    for (NSString *contentPath in contents) {
        error = nil;
        NSString *fullContentPath = [cookiesFolderPath stringByAppendingFormat:@"/%@", contentPath];
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:fullContentPath error:&error];
        if (!success) {
            JMLog(@"error of removing cookies: %@", error);
        }
    }
    completion(YES);
}

- (NSString *)cookiesAsStringFromCookies:(NSArray <NSHTTPCookie *>*)cookies
{
    NSString *cookiesAsString = @"";
    for (NSHTTPCookie *cookie in cookies) {
        NSString *name = cookie.name;
        NSString *value = cookie.value;
        NSString *path = cookie.path;
        cookiesAsString = [cookiesAsString stringByAppendingFormat:@"document.cookie = '%@=%@; expires=null, path=\\'%@\\''; ", name, value, path];
    }
    return cookiesAsString;
}

@end
