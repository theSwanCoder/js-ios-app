/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMWebViewManager.h"
#import "JMUtils.h"
#import "JMWebEnvironment.h"
#import "JMVIZWebEnvironment.h"
#import "JMRESTWebEnvironment.h"
#import "JaspersoftSDK.h"
#import "NSObject+Additions.h"

NSString *const JMWebviewManagerDidResetWebviewsNotification = @"JMWebviewManagerDidResetWebviewsNotification";

@interface JMWebViewManager()
@property (nonatomic, strong) NSMutableArray *webEnvironments;
@property (nonatomic, strong, readwrite) NSArray *__nullable cookies;
@end

@implementation JMWebViewManager

#pragma mark - Handle Memory Warnings
- (void)handleMemoryWarnings
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

#pragma mark - Lifecycle
- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance {
    static JMWebViewManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _webEnvironments = [NSMutableArray array];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMemoryWarnings)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cookiesDidChange:)
                                                     name:JSRestClientDidChangeCookies
                                                   object:nil];
    }
    return self;
}

#pragma mark - Custom Accessors
- (NSArray <NSHTTPCookie *>*)cookies
{
    if(!_cookies) {
        _cookies = self.restClient.cookies;
    }
    return _cookies;
}

#pragma mark - Public API

- (JMWebEnvironment * __nonnull)reusableWebEnvironmentWithId:(NSString * __nonnull)identifier flowType:(JMResourceFlowType)flowType
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMLog(@"identifier: %@", identifier);

    JMWebEnvironment *webEnvironment = [self findWebEnvironmentForId:identifier];
    if (!webEnvironment) {
        webEnvironment = [self createNewWebEnvironmentWithId:identifier flowType:flowType needReuse:YES];
        [self.webEnvironments addObject:webEnvironment];
    }

    return webEnvironment;
}

- (JMWebEnvironment * __nonnull)webEnvironment
{
    return [self webEnvironmentForFlowType:JMResourceFlowTypeUndefined];
}

- (JMWebEnvironment * __nonnull)webEnvironmentForFlowType:(JMResourceFlowType)flowType
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMWebEnvironment *webEnvironment = [self createNewWebEnvironmentWithId:nil flowType:flowType needReuse:NO];
    return webEnvironment;
}

// USE FOR TESTS ONLY
- (void)updateCookiesWithCookies:(NSArray <NSHTTPCookie *>*)cookies
{
    self.cookies = cookies;
    for (JMWebEnvironment *webEnvironment in self.webEnvironments) {
        [webEnvironment updateCookiesInWebView:cookies];
    }
}

#pragma mark - Private API

- (JMWebEnvironment *)createNewWebEnvironmentWithId:(NSString *)identifier flowType:(JMResourceFlowType)flowType needReuse:(BOOL)needReuse
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMWebEnvironment *webEnvironment;
    switch (flowType) {
        case JMResourceFlowTypeUndefined: {
            webEnvironment = [JMWebEnvironment webEnvironmentWithId:identifier
                                                         initialCookies:self.cookies];
            break;
        }
        case JMResourceFlowTypeREST: {
            webEnvironment = [JMRESTWebEnvironment webEnvironmentWithId:identifier
                                                         initialCookies:self.cookies];
            break;
        }
        case JMResourceFlowTypeVIZ: {
            webEnvironment = [JMVIZWebEnvironment webEnvironmentWithId:identifier
                                                        initialCookies:self.cookies];
            break;
        }
    }
    webEnvironment.reusable = needReuse;
    webEnvironment.flowType = flowType;
    return webEnvironment;
}

- (void)reset
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    for(JMWebEnvironment *webEnvironment in self.webEnvironments) {
        [webEnvironment.webView removeFromSuperview];
    }
    self.webEnvironments = [NSMutableArray array];
}

#pragma mark - Notifications
- (void)cookiesDidChange:(NSNotification *)notification
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    if ([notification.object isKindOfClass:[JSRESTBase class]]) {
        // We need set cookies from correct restClient
        JSRESTBase *restClient = notification.object;
        self.cookies = restClient.cookies;
        JMLog(@"new cookies: %@", self.cookies);
        NSAssert(self.cookies != nil, @"Cookies weren't set");
        for (JMWebEnvironment *webEnvironment in self.webEnvironments) {
            switch(webEnvironment.cookiesState) {
                case JMWebEnvironmentCookiesStateValid: {
                    webEnvironment.cookiesState = JMWebEnvironmentCookiesStateRestoreAfterNetworkRequestFailed;
                    break;
                }
                case JMWebEnvironmentCookiesStateExpire: {
                    webEnvironment.cookiesState = JMWebEnvironmentCookiesStateRestoreAfterJavascriptRequestFailed;
                    break;
                }
                case JMWebEnvironmentCookiesStateRestoreAfterJavascriptRequestFailed: {
                    // TODO: how update this state
                    break;
                }
                case JMWebEnvironmentCookiesStateRestoreAfterNetworkRequestFailed: {
                    // TODO: how update this state
                    break;
                }
            }
        }
    } else {
        // TODO: need handle this case?
    }
}

#pragma mark - Helpers
- (JMWebEnvironment *)findWebEnvironmentForId:(NSString *)identifier
{
    JMWebEnvironment *webEnvironment;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.identifier == %@", identifier];
    NSArray *filtredWebEnvironments = [self.webEnvironments filteredArrayUsingPredicate:predicate];

    if ( filtredWebEnvironments.count == 0 ) {
        return nil;
    } else if ( filtredWebEnvironments.count > 1 ) {
        return nil;
    } else {
        webEnvironment = [filtredWebEnvironments firstObject];
    }
    return webEnvironment;
}

@end
