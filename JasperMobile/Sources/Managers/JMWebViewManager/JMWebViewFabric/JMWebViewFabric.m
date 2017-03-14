/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMWebViewFabric.h"
#import "JMUtils.h"

@implementation JMWebViewFabric

#pragma mark - Life Cycle

+ (instancetype)sharedInstance
{
    static JMWebViewFabric *sharedInstance;
    static dispatch_once_t predicate;
    _dispatch_once(&predicate, ^{
        sharedInstance = [JMWebViewFabric new];
    });
    return sharedInstance;
}

#pragma mark - Public API

- (WKWebView *)createWebViewWithCookies:(NSArray <NSHTTPCookie *>*)cookies
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMLog(@"cookies: %@", cookies);
    WKWebViewConfiguration* webViewConfig = [WKWebViewConfiguration new];
    WKUserContentController *contentController = [WKUserContentController new];

    [contentController addUserScript:[self injectCookiesScriptWithCookies:cookies]];
    [contentController addUserScript:[self jaspermobileScript]];

    webViewConfig.userContentController = contentController;

    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfig];

    // From for iOS9
//    webView.customUserAgent = @"Mozilla/5.0 (Linux; Android 5.0.1; SCH-I545 Build/LRX22C) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.95 Mobile Safari/537.36";
    return webView;
}

- (NSString *)cookiesAsStringFromCookies:(NSArray <NSHTTPCookie *>*)cookies
{
    NSString *cookiesAsString = @"";
    for (NSHTTPCookie *cookie in cookies) {
        NSString *name = cookie.name;
        NSString *value = cookie.value;
        cookiesAsString = [cookiesAsString stringByAppendingFormat:@"%@=%@; ", name, value];
    }
    return cookiesAsString;
}

#pragma mark - Helpers

- (WKUserScript *)jaspermobileScript
{
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *jaspermobilePath = [bundle pathForResource:@"vis_jaspermobile"
                                                  ofType:@"js"];
    NSAssert(jaspermobilePath != nil, @"JasperMobile path should not be nil");
    NSString *jaspermobileString = [NSString stringWithContentsOfFile:jaspermobilePath
                                                             encoding:NSUTF8StringEncoding
                                                                error:nil];
    NSAssert(jaspermobileString != nil, @"JasperMobile should not be nil");
    WKUserScript *script = [[WKUserScript alloc] initWithSource:jaspermobileString
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:YES];
    return script;
}

- (WKUserScript *)injectCookiesScriptWithCookies:(NSArray <NSHTTPCookie *>*)cookies
{
    NSString *cookiesScriptAsString = [self cookiesScriptAsStringFromCookies:cookies];

    WKUserScript *script = [[WKUserScript alloc] initWithSource:cookiesScriptAsString
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:YES];
    return script;
}

- (NSString *)cookiesScriptAsStringFromCookies:(NSArray <NSHTTPCookie *>*)cookies
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
