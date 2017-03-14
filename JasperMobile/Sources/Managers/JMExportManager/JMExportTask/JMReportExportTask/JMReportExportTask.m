/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMReportExportTask.h"

@interface JMReportExportTask ()
@property (nonatomic, strong, readwrite) JSReportPagesRange *pagesRange;

@property (nonatomic, strong) JSReportSaver *reportSaver;

@end

@implementation JMReportExportTask

- (instancetype)initWithReport:(JSReport *)report name:(NSString *)name format:(NSString *)format pages:(JSReportPagesRange *)pagesRange
{
    JMExportResource *resource = [JMExportResource resourceWithResourceLookup:report.resourceLookup format:format];
    resource.resourceLookup.label = name;
    self = [super initWithResource:resource];
    if(self) {
        self.name = name;
        _pagesRange = pagesRange;
        _reportSaver = [[JSReportSaver alloc] initWithReport:report restClient:self.restClient];
    }
    return self;
}

- (void)cancel
{
    [super cancel];
    [self.reportSaver cancel];
}
#pragma mark - Overrides
- (void)main
{
    __weak typeof(self) weakSelf = self;
    [self.reportSaver saveReportWithName:self.exportResource.resourceLookup.label
                                  format:self.exportResource.format
                              pagesRange:self.pagesRange
                              completion:^(NSURL * _Nullable savedReportFolderURL, NSError * _Nullable error) {
                                  __strong typeof(self) strongSelf = weakSelf;
                                  strongSelf->_savedResourceFolderURL = savedReportFolderURL;
                                  strongSelf->_savingError = error;
                                  [strongSelf completeOperation];
                              }];
}

@end
