/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */

//
//  JMBaseWebEnvironment.h
//  TIBCO JasperMobile
//

/**
@author Aleksandr Dakhno odahno@tibco.com
@since 2.6
*/

@class JMJavascriptRequest;
@class JMJavascriptRequestExecutor;

typedef void(^JMWebEnvironmentRequestParametersCompletion)(NSDictionary *__nullable params, NSError * __nullable error);
typedef void(^JMWebEnvironmentLoadingCompletion)(BOOL isReady, NSError * __nullable error);

@protocol JMJavascriptRequestExecutionProtocol <NSObject>
- (void)sendJavascriptRequest:(JMJavascriptRequest *__nonnull)request
                   completion:(JMWebEnvironmentRequestParametersCompletion __nullable)completion;
- (void)addListener:(id __nonnull)listener
         forEventId:(NSString * __nonnull)eventId
           callback:(JMWebEnvironmentRequestParametersCompletion __nonnull)callback;
- (void)removeListener:(id __nonnull)listener;
@end

@protocol JMWebEnvironmentLoadingProtocol <NSObject>
- (void)loadRequest:(NSURLRequest * __nonnull)request;
- (void)loadHTML:(NSString * __nonnull)HTMLString
         baseURL:(NSURL * __nullable)baseURL
      completion:(JMWebEnvironmentLoadingCompletion __nullable)completion;
- (void)loadLocalFileFromURL:(NSURL * __nonnull)fileURL
                  fileFormat:(NSString * __nullable)fileFormat
                     baseURL:(NSURL * __nullable)baseURL;
@end

typedef NS_ENUM(NSInteger, JMWebEnvironmentState) {
    JMWebEnvironmentStateInitial,           // state without webview
    JMWebEnvironmentStateWebViewCreated,    // state when webview was created
    JMWebEnvironmentStateWebViewConfigured, // state when webview has html loaded
    JMWebEnvironmentStateEnvironmentReady,  // state when webview has scripts loaded
    JMWebEnvironmentStateSessionExpired,    // cookies became not valid
    JMWebEnvironmentStateCancel             // cancel signal was sent
};

@interface JMBaseWebEnvironment : NSObject <JMJavascriptRequestExecutionProtocol, JMWebEnvironmentLoadingProtocol>
@property (nonatomic, assign) JMWebEnvironmentState state;
@property (nonatomic, strong, readonly) WKWebView * __nullable webView;
@property (nonatomic, copy, readonly) NSString * __nonnull identifier;
@property (nonatomic, assign, getter=isReusable) BOOL reusable; // TODO: remove
@property (nonatomic, strong) JMJavascriptRequestExecutor * __nonnull requestExecutor;

- (instancetype __nullable)initWithId:(NSString *__nonnull)identifier initialCookies:(NSArray *__nullable)cookies;
+ (instancetype __nullable)webEnvironmentWithId:(NSString *__nullable)identifier initialCookies:(NSArray *__nullable)cookies;
// PUBLIC API
- (NSOperation *__nullable)taskForPreparingWebView;
- (NSOperation *__nullable)taskForPreparingEnvironment;
- (void)resetZoom;
- (void)clean;
- (void)reset;
@end