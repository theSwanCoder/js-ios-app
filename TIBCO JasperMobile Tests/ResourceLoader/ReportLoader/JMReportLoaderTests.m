//
// Created by Aleksandr Dakhno on 12/27/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMReportLoaderTests.h"
#import "JMReportLoaderProtocol.h"

@implementation JMReportLoaderTests

#pragma mark - Setups

- (void)setUp
{
    [super setUp];

}

- (void)tearDown
{
    [self.loader reset];
    self.loader = nil;
    [super tearDown];
}

#pragma mark - Helpers

- (JSReport *)highchartReportWithoutFilters
{
    JSResourceLookup *resourceLookup = [JSResourceLookup new];
    resourceLookup.label = @"02. Sales Mix by Demographic Report";
    resourceLookup.uri = @"/public/Samples/Reports/02._Sales_Mix_by_Demographic_Report";
    resourceLookup.resourceDescription = @"Sample HTML5 Spider Line chart from OLAP source. Created from an Ad Hoc View.";
    resourceLookup.resourceType = @"reportUnit";
    resourceLookup.version = @1;
    resourceLookup.permissionMask = @2;
    JSReport *report = [JSReport reportWithResourceLookup:resourceLookup];
    return report;
}

- (JSReport *)customersReportOnTrunkCE
{
    JSResourceLookup *resourceLookup = [JSResourceLookup new];
    resourceLookup.label = @"Customers Report";
    resourceLookup.uri = @"/reports/interactive/CustomersReport";
    resourceLookup.resourceDescription = @"Customers Report";
    resourceLookup.resourceType = @"reportUnit";
    resourceLookup.version = @1;
    resourceLookup.permissionMask = @2;
    JSReport *report = [JSReport reportWithResourceLookup:resourceLookup];
    return report;
}

- (JSReport *)highchartReportWithFilters
{
    JSResourceLookup *resourceLookup = [JSResourceLookup new];
    resourceLookup.label = @"01. Geographic Results by Segment Report";
    resourceLookup.uri = @"/public/Samples/Reports/01._Geographic_Results_by_Segment_Report";
    resourceLookup.resourceDescription = @"Sample HTML5 multi-axis column chart from Domain showing Sales, Units, and $ Per Square Foot by Country and Store Type with various filters. Created from an Ad Hoc View.";
    resourceLookup.resourceType = @"reportUnit";
    resourceLookup.version = @1;
    resourceLookup.permissionMask = @2;
    JSReport *report = [JSReport reportWithResourceLookup:resourceLookup];
    return report;
}

- (JSReport *)multipageReportWithoutFilters
{
    JSResourceLookup *resourceLookup = [JSResourceLookup new];
    resourceLookup.label = @"05. Accounts Report";
    resourceLookup.uri = @"/public/Samples/Reports/AllAccounts";
    resourceLookup.resourceDescription = @"Basic interactive Table Component report with Bookmarks Panel";
    resourceLookup.resourceType = @"reportUnit";
    resourceLookup.version = @1;
    resourceLookup.permissionMask = @2;
    JSReport *report = [JSReport reportWithResourceLookup:resourceLookup];
    return report;
}

#pragma mark - Tasks

- (NSOperation * __nonnull)runReportTaskWithReport:(JSReport *)report
                                        completion:(JMTestBooleanCompletion __nonnull)completion;
{
    JMAsyncTask *runReportTask = [[JMAsyncTask alloc] initWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start run report task");
        JSReportDestination *initialDestination = [JSReportDestination new];
        initialDestination.page = 1;
        [self.loader runReport:report
            initialDestination:initialDestination
             initialParameters:nil
                    completion:^(BOOL success, NSError *error) {
                        completion(success, error);
                        finishBlock();
                        NSLog(@"End run report task");
                    }];
    }];
    return runReportTask;
}

- (NSOperation *)refreshReportTaskWithCompletion:(JMTestBooleanCompletion __nonnull)completion
{
    JMAsyncTask *refreshReportTask = [[JMAsyncTask alloc] initWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start refresh report task");
        [self.loader refreshReportWithCompletion:^(BOOL success, NSError *error) {
            completion(success, error);
            finishBlock();
            NSLog(@"End refresh report task");
        }];
    }];
    return refreshReportTask;
}

- (NSOperation *)navigateToTaskWithPage:(NSInteger)page
                             completion:(JMTestBooleanCompletion __nonnull)completion
{
    JMAsyncTask *prepareWebEnvironmentTask = [[JMAsyncTask alloc] initWithExecutionBlock:^(JMAsyncTaskFinishBlock finishBlock) {
        NSLog(@"Start navigating to page task");
        [self.loader fetchPage:@(page)
                    completion:^(BOOL success, NSError *error) {
                        completion(success, error);
                        finishBlock();
                        NSLog(@"End navigating to page task");
                    }];
    }];
    return prepareWebEnvironmentTask;
}

@end
