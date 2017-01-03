//
// Created by Aleksandr Dakhno on 12/27/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

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
