/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMVIZWebEnvironment.h"
#import "JMVisualizeManager.h"
#import "JMJavascriptRequest.h"
#import "JMServerOptionManager.h"
#import "JMWebEnvironmentLoadingTask.h"
#import "JMJavascriptRequestTask.h"
#import "NSObject+Additions.h"
#import "JMUtils.h"

@implementation JMVIZWebEnvironment

#pragma mark - Init
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype __nullable)initWithId:(NSString *__nonnull)identifier initialCookies:(NSArray *__nullable)cookies;
{
    self = [super initWithId:identifier initialCookies:cookies];
    if (self) {
        _visualizeManager = [JMVisualizeManager new];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cacheReportsOptionDidChange:)
                                                     name:JMCacheReportsOptionDidChangeNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Notification
- (void)cacheReportsOptionDidChange:(NSNotification *)notification
{
    JMServerProfile *serverProfile = notification.object;
    [self cleanCache];
    [self removeContainers];
    if (serverProfile.cacheReports.boolValue) {
        [self createContainers];
    }
}

#pragma mark - Public API

- (NSOperation *__nullable)taskForPreparingWebView
{
    __weak __typeof(self) weakSelf = self;
    JMWebEnvironmentLoadingTask *loadingTask = [JMWebEnvironmentLoadingTask taskWithRequestExecutor:self.requestExecutor
                                                                                         HTMLString:self.visualizeManager.htmlString
                                                                                            baseURL:[NSURL URLWithString:self.restClient.serverProfile.serverUrl]
                                                                                         completion:^{
                                                                                             __strong __typeof(self) strongSelf = weakSelf;
                                                                                             strongSelf.cookiesState = JMWebEnvironmentCookiesStateValid;
                                                                                         }];
    return loadingTask;
}

- (NSOperation *__nullable)taskForPreparingEnvironment
{
    NSString *vizPath = self.visualizeManager.visualizePath;
    JMJavascriptRequest *requireJSLoadRequest = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.loadScripts"
                                                                            inNamespace:JMJavascriptNamespaceDefault
                                                                             parameters:@{
                                                                                     @"scriptURLs" : @[
                                                                                             vizPath,
                                                                                             @"https://code.jquery.com/jquery.min.js"
                                                                                     ]
                                                                             }];
    __weak  __typeof(self) weakSelf = self;
    JMJavascriptRequestTask *requestTask = [JMJavascriptRequestTask taskWithRequestExecutor:self.requestExecutor
                                                                                    request:requireJSLoadRequest
                                                                                 completion:^(NSDictionary *params, NSError *error) {
                                                                                     __strong __typeof(self) strongSelf = weakSelf;
                                                                                     if (error) {
                                                                                         JMLog(@"Error of loading scripts: %@", error);
                                                                                     } else {
                                                                                         strongSelf.state = JMWebEnvironmentStateEnvironmentReady;
                                                                                     }
                                                                                 }];
    return requestTask;
}

- (void)updateViewportScaleFactorWithValue:(CGFloat)scaleFactor
{
    BOOL isInitialScaleFactorSet = self.visualizeManager.viewportScaleFactor > 0.01;
    BOOL isInitialScaleFactorTheSame = fabs(self.visualizeManager.viewportScaleFactor - scaleFactor) >= 0.49;
    if ( !isInitialScaleFactorSet || isInitialScaleFactorTheSame ) {
        self.visualizeManager.viewportScaleFactor = scaleFactor;

        JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.Helper.updateViewPortScale"
                                                                   inNamespace:JMJavascriptNamespaceDefault
                                                                    parameters:@{
                                                                            @"scale" : @(scaleFactor)
                                                                    }];
        [self sendJavascriptRequest:request
                         completion:nil];
    }
}

// delete
- (void)cleanCache
{
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"reset"
                                                               inNamespace:JMJavascriptNamespaceVISReport
                                                                parameters:nil];
    [self sendJavascriptRequest:request
                     completion:nil];
}

#pragma mark - Helpers

- (void)removeContainers
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.containerManager.removeAllContainers"
                                                               inNamespace:JMJavascriptNamespaceDefault
                                                                parameters:nil];
    [self sendJavascriptRequest:request
                     completion:nil];
}

- (void)createContainers
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.containerManager.setContainers"
                                                               inNamespace:JMJavascriptNamespaceDefault
                                                                parameters:@{
                                                                        @"containers" : @[
                                                                                @{
                                                                                        @"name" : @"container",
                                                                                        @"isActive" : @NO
                                                                                },
                                                                                @{
                                                                                        @"name" : @"container1",
                                                                                        @"isActive" : @NO
                                                                                },
                                                                                @{
                                                                                        @"name" : @"container2",
                                                                                        @"isActive" : @NO
                                                                                },
                                                                        ]
                                                                }];
    [self sendJavascriptRequest:request
                     completion:nil];
}

@end
