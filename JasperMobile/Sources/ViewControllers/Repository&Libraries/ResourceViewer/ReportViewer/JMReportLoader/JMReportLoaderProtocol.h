/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
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
@class JMReportChartType;

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
- (void)fetchAvailableChartTypesWithCompletion:(void(^__nonnull)(NSArray <JMReportChartType *>*__nullable, NSError *__nullable ))completion;
- (void)updateComponent:(JSReportComponent *__nonnull)component withNewChartType:(JMReportChartType *__nonnull)chartType completion:(JSReportLoaderCompletionBlock __nullable)completion;
@end

@protocol JMReportLoaderDelegate <NSObject>
@optional
- (void)reportLoader:(id<JMReportLoaderProtocol> __nonnull)loader didReceiveEventWithHyperlink:(JMHyperlink *__nonnull)hyperlink;
- (void)reportLoaderDidReceiveEventWithUnsupportedHyperlink:(id<JMReportLoaderProtocol> __nonnull)loader;
@end

