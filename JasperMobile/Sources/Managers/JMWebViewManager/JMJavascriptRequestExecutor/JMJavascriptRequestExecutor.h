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
//  JMJavascriptRequestExecutor.h
//  TIBCO JasperMobile
//

/**
@author Aleksandr Dakhno odahno@tibco.com
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

