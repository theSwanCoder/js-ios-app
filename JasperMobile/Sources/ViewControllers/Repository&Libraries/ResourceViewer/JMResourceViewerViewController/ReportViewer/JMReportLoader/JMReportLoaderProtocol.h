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
//  JMReportLoaderProtocol.h
//  TIBCO JasperMobile
//

/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 2.3
 */

#import "JSReportLoaderProtocol.h"
#import "JMJavascriptNativeBridge.h"

@protocol JMReportLoaderDelegate;
@class JMWebEnvironment;

@protocol JMReportLoaderProtocol <JSReportLoaderProtocol>

- (void)setDelegate:(id<JMReportLoaderDelegate> __nullable)delegate;
- (void)destroy;

@optional
- (nullable id<JMReportLoaderProtocol>)initWithReport:(nonnull JSReport *)report
                                        restClient:(nonnull JSRESTBase *)restClient
                                    webEnvironment:(nonnull JMWebEnvironment *)webEnvironment;
+ (nullable id<JMReportLoaderProtocol>)loaderWithReport:(nonnull JSReport *)report
                                           restClient:(nonnull JSRESTBase *)restClient
                                       webEnvironment:(nonnull JMWebEnvironment *)webEnvironment;
- (void)exportReportWithFormat:(NSString * __nonnull)exportFormat;
- (void)updateViewportScaleFactorWithValue:(CGFloat)scaleFactor;
- (void)fitReportViewToScreen;
@end

@protocol JMReportLoaderDelegate <NSObject>
@optional
- (void)reportLoader:(id<JMReportLoaderProtocol> __nonnull)reportLoader didReceiveOnClickEventForResourceLookup:(JSResourceLookup *__nonnull)resourceLookup withParameters:(NSArray *__nullable)reportParameters;
- (void)reportLoader:(id<JMReportLoaderProtocol> __nonnull)reportLoader didReceiveOnClickEventWithError:(NSError *__nonnull)error;
- (void)reportLoader:(id<JMReportLoaderProtocol> __nonnull)reportLoder didReceiveOnClickEventForReference:(NSURL *__nonnull)urlReference;
- (void)reportLoader:(id<JMReportLoaderProtocol> __nonnull)reportLoader didReceiveOutputResourcePath:(NSString *__nonnull)resourcePath fullReportName:(NSString *__nonnull)fullReportName;
@end

