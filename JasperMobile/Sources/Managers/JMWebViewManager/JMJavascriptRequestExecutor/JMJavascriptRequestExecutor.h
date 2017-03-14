/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.1
 */

@import WebKit;
#import "JMJavascriptRequest.h"
#import "JMJavascriptResponse.h"
@protocol JMJavascriptRequestExecutorDelegate;
@class JMJavascriptEvent;

extern NSString *const __nonnull JMJavascriptRequestExecutorErrorCodeKey;

typedef void(^JMJavascriptRequestCompletion)(JMJavascriptResponse *__nullable response, NSError * __nullable error);

@interface JMJavascriptRequestExecutor : NSObject
@property (nonatomic, weak, readonly, nullable) WKWebView *webView;
@property (nonatomic, weak, nullable) id <JMJavascriptRequestExecutorDelegate>delegate;

- (instancetype __nullable)initWithWebView:(WKWebView * __nonnull)webView;
+ (instancetype __nullable)executorWithWebView:(WKWebView * __nonnull)webView;

- (void)startLoadHTMLString:(NSString *__nonnull)HTMLString
                    baseURL:(NSURL *__nonnull)baseURL;
// js requests
- (void)sendJavascriptRequest:(JMJavascriptRequest *__nonnull)request
                   completion:(JMJavascriptRequestCompletion __nullable)completion;
// event listeners
- (void)addListenerWithEvent:(JMJavascriptEvent * __nonnull)event;
- (void)removeListener:(id __nonnull)listener;
- (void)reset;
@end

@protocol JMJavascriptRequestExecutorDelegate <NSObject>
@optional
- (void)javascriptRequestExecutor:(JMJavascriptRequestExecutor *__nonnull)executor didReceiveError:(NSError *__nonnull)error;
- (BOOL)javascriptRequestExecutor:(JMJavascriptRequestExecutor *__nonnull)executor shouldLoadExternalRequest:(NSURLRequest * __nonnull)request;
@end

