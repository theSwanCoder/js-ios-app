/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMSaveDashboardViewController.h"
#import "JMDashboardExportTask.h"
#import "JMExportManager.h"


@implementation JMSaveDashboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.resourceName = self.dashboard.resourceLookup.label;
}

- (JMResourceType)resourceType
{
    return [JMResource typeForResourceLookupType:self.dashboard.resourceLookup.resourceType];
}


-(NSArray *)availableFormats
{
    return [JMUtils supportedFormatsForDashboardSaving];
}

- (void) saveResource
{
    JMDashboardExportTask *task = [[JMDashboardExportTask alloc] initWithDashboard:self.dashboard name:self.resourceName format:self.selectedFormat];
    [[JMExportManager sharedInstance] saveResourceWithTask:task];
    
    [super saveResource];
}

@end
