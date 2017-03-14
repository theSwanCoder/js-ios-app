/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMResourceLoaderBaseTests.h"

@interface JMReportLoaderTests : JMResourceLoaderBaseTests
@property (nonatomic, strong, nullable) id<JMReportLoaderProtocol> loader;

- (JSReport *__nonnull)highchartReportWithoutFilters;
- (JSReport *__nonnull)customersReportOnTrunkCE;
- (JSReport *__nonnull)highchartReportWithFilters;
- (JSReport *__nonnull)multipageReportWithoutFilters;

- (NSOperation * __nonnull)runReportTaskWithReport:(JSReport *__nonnull)report
                                        completion:(JMTestBooleanCompletion __nonnull)completion;
- (NSOperation * __nonnull)refreshReportTaskWithCompletion:(JMTestBooleanCompletion __nonnull)completion;
- (NSOperation *__nonnull)navigateToTaskWithPage:(NSInteger)page
                                      completion:(JMTestBooleanCompletion __nonnull)completion;
@end
