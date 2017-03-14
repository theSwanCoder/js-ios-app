/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import <WebKit/WebKit.h>

@class JMJavascriptRequest;
@class JMJavascriptRequestExecutor;

typedef void(^JMWebEnvironmentRequestParametersCompletion)(NSDictionary *__nullable params, NSError * __nullable error);
typedef void(^JMWebEnvironmentLoadingCompletion)(BOOL isReady, NSError * __nullable error);

@protocol JMJavascriptRequestExecutionProtocol <NSObject>
- (BOOL)canSendJavascriptRequest;
- (void)sendJavascriptRequest:(JMJavascriptRequest *__nonnull)request
                   completion:(JMWebEnvironmentRequestParametersCompletion __nullable)completion;
- (void)sendJavascriptRequest:(JMJavascriptRequest *__nonnull)request
                   completion:(JMWebEnvironmentRequestParametersCompletion __nullable)completion
             needSessionValid:(BOOL)needSessionValid;
- (void)addListener:(id __nonnull)listener
         forEventId:(NSString * __nonnull)eventId
           callback:(JMWebEnvironmentRequestParametersCompletion __nonnull)callback;
- (void)removeListener:(id __nonnull)listener;
@end

@protocol JMWebEnvironmentLoadingProtocol <NSObject>
- (void)loadRequest:(NSURLRequest * __nonnull)request
         completion:(JMWebEnvironmentLoadingCompletion __nullable)completion;
- (void)loadHTML:(NSString * __nonnull)HTMLString
         baseURL:(NSURL * __nullable)baseURL
      completion:(JMWebEnvironmentLoadingCompletion __nullable)completion;
- (void)loadLocalFileFromURL:(NSURL * __nonnull)fileURL
                  fileFormat:(NSString * __nullable)fileFormat
                     baseURL:(NSURL * __nullable)baseURL;
@end

typedef NS_ENUM(NSInteger, JMWebEnvironmentState) {
    JMWebEnvironmentStateWithoutWebView,   // state without webview
    JMWebEnvironmentStateEmptyWebView,     // state when webview was created
    JMWebEnvironmentStateWebViewReady,     // state when webview has html loaded
    JMWebEnvironmentStateEnvironmentReady, // state when webview has scripts loaded
    JMWebEnvironmentStateCancel            // cancel signal was sent
};

typedef NS_ENUM(NSInteger, JMWebEnvironmentCookiesState) {
    JMWebEnvironmentCookiesStateValid,
    JMWebEnvironmentCookiesStateExpire,
    JMWebEnvironmentCookiesStateRestoreAfterJavascriptRequestFailed,
    JMWebEnvironmentCookiesStateRestoreAfterNetworkRequestFailed
};

@interface JMBaseWebEnvironment : NSObject <JMJavascriptRequestExecutionProtocol, JMWebEnvironmentLoadingProtocol>
@property (nonatomic, assign) JMWebEnvironmentState state;
@property (nonatomic, assign) JMWebEnvironmentCookiesState cookiesState;
@property (nonatomic, strong, readonly, nullable) WKWebView *webView;
@property (nonatomic, copy, readonly, nonnull) NSString *identifier;
@property (nonatomic, assign, getter=isReusable) BOOL reusable; // TODO: remove
@property (nonatomic, strong, nullable) JMJavascriptRequestExecutor *requestExecutor;

- (instancetype __nullable)initWithId:(NSString *__nonnull)identifier initialCookies:(NSArray *__nullable)cookies;
+ (instancetype __nullable)webEnvironmentWithId:(NSString *__nullable)identifier initialCookies:(NSArray *__nullable)cookies;
// PUBLIC API
- (NSOperation *__nullable)taskForPreparingWebView;
- (NSOperation *__nullable)taskForPreparingEnvironment;
- (NSString *__nonnull)stateNameForState:(JMWebEnvironmentState)state;
- (void)resetZoom;
- (void)clean;
- (void)cancel;
- (void)reset;
@end
