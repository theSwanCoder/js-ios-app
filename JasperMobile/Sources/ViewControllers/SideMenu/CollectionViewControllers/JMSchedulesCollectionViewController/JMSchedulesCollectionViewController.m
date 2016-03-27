/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMSchedulesCollectionViewController.m
//  TIBCO JasperMobile
//

#import "JMSchedulesCollectionViewController.h"
#import "ALToastView.h"
#import "JMScheduleManager.h"
#import "JMSchedule.h"
#import "JMScheduleVC.h"


@implementation JMSchedulesCollectionViewController

#pragma mark - LifeCycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = JMCustomLocalizedString(@"menuitem.schedules.label", nil);
}


#pragma mark - Overloaded methods
- (NSString *)defaultRepresentationTypeKey
{
    NSString * keyString = @"RepresentationTypeKey";
    keyString = [@"Schedules" stringByAppendingString:keyString];
    return keyString;
}

- (JMMenuActionsViewAction)availableAction
{
    return JMMenuActionsViewAction_None;
}

- (NSString *)noResultText
{
    return JMCustomLocalizedString(@"resources.noresults.saveditems.msg", nil);
}

- (Class)resourceLoaderClass
{
    return NSClassFromString(@"JMSchedulesListLoader");
}

- (void)actionForResource:(JMResource *)resource
{
    JMSchedule *schedule = (JMSchedule *) resource;
    // TODO: add loader
    [[JMScheduleManager sharedManager] loadScheduleMetadataForScheduleWithId:schedule.scheduleLookup.jobIdentifier completion:^(JSScheduleMetadata *metadata, NSError *error) {
        if (metadata) {
            JMScheduleVC *newScheduleVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"JMScheduleVC"];
            newScheduleVC.scheduleMetadata = metadata;
            newScheduleVC.exitBlock = ^(JSScheduleMetadata *scheduleMetadata) {
                if (scheduleMetadata) {
                    [[JMScheduleManager sharedManager] updateSchedule:scheduleMetadata
                                                           completion:^(JSScheduleMetadata *updatedScheduleMetadata, NSError *error) {
                                                               if (updatedScheduleMetadata) {
                                                                   [self.navigationController popViewControllerAnimated:YES];
                                                                   [ALToastView toastInView:self.navigationController.view
                                                                                   withText:JMCustomLocalizedString(@"Schedule was updated successfully.", nil)];
                                                               } else {
                                                                   [JMUtils presentAlertControllerWithError:error
                                                                                                 completion:nil];
                                                               }
                                                           }];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            };
            [self.navigationController pushViewController:newScheduleVC animated:YES];
        } else {
            [JMUtils presentAlertControllerWithError:error
                                          completion:nil];
        }
    }];
}

@end