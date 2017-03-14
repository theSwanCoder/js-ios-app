/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMDashboardExportTask.h"

@interface JMDashboardExportTask ()
@property (nonatomic, strong) JSDashboardSaver *dashboardSaver;

@end

@implementation JMDashboardExportTask
- (instancetype)initWithDashboard:(JSDashboard *)dashboard name:(NSString *)name format:(NSString *)format
{
    JMExportResource *resource = [JMExportResource resourceWithResourceLookup:dashboard.resourceLookup format:format];
    resource.resourceLookup.label = name;
    self = [super initWithResource:resource];
    if(self) {
        self.name = name;
        _dashboardSaver = [[JSDashboardSaver alloc] initWithDashboard:dashboard restClient:self.restClient];
    }
    return self;
}

- (void)cancel
{
    [super cancel];
    [self.dashboardSaver cancel];
}

#pragma mark - Overrides
- (void)main
{
    __weak typeof(self) weakSelf = self;
    [self.dashboardSaver saveDashboardWithName:self.exportResource.resourceLookup.label
                                        format:self.exportResource.format
                                    completion:^(NSURL * _Nullable savedDashboardFolderURL, NSError * _Nullable error) {
                                        __strong typeof(self) strongSelf = weakSelf;
                                        strongSelf->_savedResourceFolderURL = savedDashboardFolderURL;
                                        strongSelf->_savingError = error;
                                        [strongSelf completeOperation];
                                    }];
}

@end
