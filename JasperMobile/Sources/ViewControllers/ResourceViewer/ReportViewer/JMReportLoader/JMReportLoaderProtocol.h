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

@protocol JMReportLoaderDelegate;
@class JMWebEnvironment;
@class JMResource;
@class JSReportBookmark;
@class JSReportPart;
@class JSReportDestination;
@class JMHyperlink;

typedef void(^JSReportLoaderBaseCompletionBlock)();

@protocol JMReportLoaderProtocol <JSReportLoaderProtocol>
@optional
- (void)setDelegate:(id<JMReportLoaderDelegate> __nullable)delegate;

- (nullable id<JMReportLoaderProtocol>)initWithRestClient:(nonnull JSRESTBase *)restClient
                                           webEnvironment:(nonnull JMWebEnvironment *)webEnvironment;
+ (nullable id<JMReportLoaderProtocol>)loaderWithRestClient:(nonnull JSRESTBase *)restClient
                                             webEnvironment:(nonnull JMWebEnvironment *)webEnvironment;
- (void)runReport:(nonnull JSReport *)report
initialDestination:(nullable JSReportDestination *)destination
        initialParameters:(nullable NSArray <JSReportParameter *> *)initialParameters
        completion:(nonnull JSReportLoaderCompletionBlock)completion;
- (void)navigateToBookmark:(nonnull JSReportBookmark *)bookmark
                completion:(nonnull JSReportLoaderCompletionBlock)completion; /** @since 2.6 */
- (void)navigateToPart:(nonnull JSReportPart *)part
            completion:(nonnull JSReportLoaderCompletionBlock)completion; /** @since 2.6 */
- (void)destroyWithCompletion:(nullable JSReportLoaderBaseCompletionBlock)completion;
- (void)fitReportViewToScreen;
- (void)resetWithCompletion:(nullable JSReportLoaderBaseCompletionBlock)completion;
- (void)fetchAvailableChartTypesWithCompletion:(JSReportLoaderCompletionBlock __nonnull)completion;
@end

@protocol JMReportLoaderDelegate <NSObject>
@optional
- (void)reportLoader:(id<JMReportLoaderProtocol> __nonnull)loader didReceiveEventWithHyperlink:(JMHyperlink *__nonnull)hyperlink;
- (void)reportLoaderDidReceiveEventWithUnsupportedHyperlink:(id<JMReportLoaderProtocol> __nonnull)loader;
@end

