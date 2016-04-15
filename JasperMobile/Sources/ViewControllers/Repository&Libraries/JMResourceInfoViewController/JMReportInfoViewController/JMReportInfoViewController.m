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
//  JMReportInfoViewController.m
//  TIBCO JasperMobile
//
#import "JMReportInfoViewController.h"
#import "JMScheduleVC.h"
#import "ALToastView.h"
#import "JMScheduleManager.h"
#import "JMResource.h"

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
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}

- (void)scheduleReport {
    JMScheduleVC *newJobVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"JMScheduleVC"];
    newJobVC.scheduleMetadata = [[JMScheduleManager sharedManager] createNewScheduleMetadataWithResourceLookup:self.resource];
    newJobVC.exitBlock = ^(JSScheduleMetadata *scheduleMetadata){
        if (scheduleMetadata) {
            [[JMScheduleManager sharedManager] createScheduleWithData:scheduleMetadata
                                                           completion:^(JSScheduleMetadata *newScheduleMetadata, NSError *error) {
                                                               if (newScheduleMetadata) {
                                                                   [self.navigationController popViewControllerAnimated:YES];
                                                                   [ALToastView toastInView:self.navigationController.view
                                                                                   withText:JMCustomLocalizedString(@"Schedule was created successfully.", nil)];
                                                               } else {
                                                                   [JMUtils presentAlertControllerWithError:error
                                                                                                 completion:nil];
                                                               }
                                                           }];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    [self.navigationController pushViewController:newJobVC animated:YES];
}

@end
