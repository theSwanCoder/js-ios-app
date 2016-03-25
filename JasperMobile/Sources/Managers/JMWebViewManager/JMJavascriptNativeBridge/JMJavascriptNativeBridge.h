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
//  JMJavascriptNativeBridge.h
//  TIBCO JasperMobile
//

/**
@author Aleksandr Dakhno odahno@tibco.com
@since 2.1
*/

#import "JMJavascriptRequest.h"
#import "JMJavascriptCallback.h"
@protocol JMJavascriptNativeBridgeDelegate;

typedef NS_ENUM(NSInteger, JMJavascriptNativeBrigdeErrorType) {
    JMJavascriptNativeBridgeErrorTypeWindow,
    JMJavascriptNativeBridgeErrorAuthError,
    JMJavascriptNativeBridgeErrorTypeOther,
};

typedef void(^JMJavascriptRequestCompletion)(JMJavascriptCallback *__nullable callback, NSError * __nullable error);

@interface JMJavascriptNativeBridge : NSObject
@property (nonatomic, weak, readonly, nullable) WKWebView *webView;
@property (nonatomic, weak, nullable) id <JMJavascriptNativeBridgeDelegate>delegate;

- (instancetype __nullable)initWithWebView:(WKWebView * __nonnull)webView;
+ (instancetype __nullable)bridgeWithWebView:(WKWebView * __nonnull)webView;

- (void)startLoadHTMLString:(NSString *__nonnull)HTMLString
                    baseURL:(NSURL *__nonnull)baseURL
                 completion:(JMJavascriptRequestCompletion __nullable)completion;

- (void)injectJSInitCode:(NSString * __nonnull)jsCode;

// js requests
- (void)sendJavascriptRequest:(JMJavascriptRequest *__nonnull)request
                   completion:(JMJavascriptRequestCompletion __nullable)completion;
- (void)reset;

// listeners
- (void)addListenerWithId:(NSString *__nonnull)listenerId callback:(JMJavascriptRequestCompletion __nullable)callback;
- (void)removeAllListeners;
@end

@protocol JMJavascriptNativeBridgeDelegate <NSObject>
@optional
- (void)javascriptNativeBridgeDidReceiveAuthRequest:(JMJavascriptNativeBridge *__nonnull)bridge;
- (void)javascriptNativeBridge:(JMJavascriptNativeBridge *__nonnull)bridge didReceiveOnWindowError:(NSError *__nonnull)error;
- (BOOL)javascriptNativeBridge:(JMJavascriptNativeBridge *__nonnull)bridge shouldLoadExternalRequest:(NSURLRequest * __nonnull)request;
@end

