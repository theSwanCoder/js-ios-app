/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMReportInfoViewController.h"
#import "JMScheduleVC.h"
#import "JMResource.h"
#import "JMReportViewerVC.h"
#import "JMUtils.h"

@interface JMReportInfoViewController ()

@end

@implementation JMReportInfoViewController
#pragma mark - Overloaded methods
- (JMMenuActionsViewAction)availableAction
{
    return ([super availableAction] | JMMenuActionsViewAction_Run | JMMenuActionsViewAction_Schedule);
}

- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    if (action == JMMenuActionsViewAction_Run) {
        [self runReport];
    } else if (action == JMMenuActionsViewAction_Schedule) {
        [self scheduleReport];
    }
}

#pragma mark - Private API
- (void)runReport
{
    id nextVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:[self.resource resourceViewerVCIdentifier]];
    if ([nextVC respondsToSelector:@selector(setResource:)]) {
        [nextVC setResource:self.resource];
    }
    
    if (nextVC) {
        JMReportViewerVC *reportViewerVC = (JMReportViewerVC *)nextVC;
        reportViewerVC.configurator = [JMUtils reportViewerConfiguratorReusableWebView];
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}

- (void)scheduleReport {
    JMScheduleVC *newJobVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMScheduleVC"];
    [newJobVC createNewScheduleMetadataWithResourceLookup:self.resource];
    [self.navigationController pushViewController:newJobVC animated:YES];
}

@end
