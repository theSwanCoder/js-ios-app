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
//  JMWebEnvironment.h
//  TIBCO JasperMobile
//


@class JMJavascriptRequest;

/**
@author Aleksandr Dakhno odahno@tibco.com
@since 2.4
*/

extern NSString * __nonnull const JMWebEnvironmentDidResetNotification;

typedef void(^JMWebEnvironmentPendingBlock)(void);
typedef void(^JMWebEnvironmentRequestParametersCompletion)(NSDictionary *__nullable params, NSError * __nullable error);

@interface JMWebEnvironment : NSObject
@property (nonatomic, strong) WKWebView * __nullable webView;
@property (nonatomic, copy) NSString * __nonnull identifier;
@property (nonatomic, assign, getter=isReusable) BOOL reusable;
@property (nonatomic, assign, getter=isReady) BOOL ready;

- (instancetype __nullable)initWithId:(NSString *__nonnull)identifier initialCookies:(NSArray *__nullable)cookies;
+ (instancetype __nullable)webEnvironmentWithId:(NSString *__nullable)identifier initialCookies:(NSArray *__nullable)cookies;
- (void)verifyJasperMobileEnableWithCompletion:(void (^ __nonnull)(BOOL isEnable))completion;
- (void)updateCookiesWithCookies:(NSArray *__nullable)cookies;
- (void)addPendingBlock:(JMWebEnvironmentPendingBlock __nonnull)pendingBlock;
- (void)loadRequest:(NSURLRequest * __nonnull)request;
- (void)loadHTML:(NSString * __nonnull)HTMLString
         baseURL:(NSURL * __nullable)baseURL;
- (void)loadLocalFileFromURL:(NSURL * __nonnull)fileURL
                  fileFormat:(NSString * __nullable)fileFormat
                     baseURL:(NSURL * __nullable)baseURL;

- (void)sendJavascriptRequest:(JMJavascriptRequest *__nonnull)request
                   completion:(JMWebEnvironmentRequestParametersCompletion __nullable)completion;

- (void)addListenerWithId:(NSString *__nonnull)listenerId
                 callback:(JMWebEnvironmentRequestParametersCompletion __nonnull)callback;
- (void)removeAllListeners;
- (void)cleanCache;
- (void)resetZoom;
- (void)clean;
- (void)reset;
@end