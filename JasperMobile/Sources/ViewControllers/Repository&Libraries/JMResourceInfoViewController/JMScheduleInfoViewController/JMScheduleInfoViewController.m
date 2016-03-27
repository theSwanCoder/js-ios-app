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
//  JMScheduleInfoViewController.m
//  TIBCO JasperMobile
//

#import "JMScheduleInfoViewController.h"
#import "JMResource.h"
#import "JMSchedule.h"
#import "JMScheduleManager.h"
#import "JMScheduleVC.h"
#import "ALToastView.h"


@implementation JMScheduleInfoViewController

#pragma mark - View Controller LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.resourceProperties = [self createResourceProperties];
}

#pragma mark - Accessibility
- (NSString *)accessibilityIdentifier
{
    return @"JMScheduleInfoViewAccessibilityId";
}

#pragma mark - Menu Actions
- (JMMenuActionsViewAction)availableAction
{
    return (JMMenuActionsViewAction_Edit | JMMenuActionsViewAction_Delete);
}

- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    switch (action) {
        case JMMenuActionsViewAction_Edit: {
            [self editSchedule];
            break;
        }
        case JMMenuActionsViewAction_Delete: {
            [self deleteSchedule];
            break;
        }
        default: {
            NSString *reason = [NSString stringWithFormat:@"Wrong action: %@", @(action)];
            NSException* wrongActionException = [NSException exceptionWithName:@"ScheduleInfoViewException"
                                                                       reason:reason
                                                                     userInfo:nil];
            @throw wrongActionException;
        }
    }
}

#pragma mark - Private API
- (NSArray *)createResourceProperties
{
    JSScheduleLookup *scheduleLookup = [self scheduleLookup];
    if (!scheduleLookup) {
        return nil;
    }
    NSArray *resourceProperties = @[
            @{
                    kJMTitleKey : @"type",
                    kJMValueKey : [self.resource localizedResourceType] ?: @"-"
            },
            @{
                    kJMTitleKey : @"version",
                    kJMValueKey : [NSString stringWithFormat:@"%@", @(scheduleLookup.version)]
            },
            @{
                    kJMTitleKey : @"label",
                    kJMValueKey : scheduleLookup.label ?: @"-"
            },
            @{
                    kJMTitleKey : @"description",
                    kJMValueKey : scheduleLookup.scheduleDescription ?: @"-"
            },
            @{
                    kJMTitleKey : @"owner",
                    kJMValueKey : scheduleLookup.owner ?: @"-"
            },
            @{
                    kJMTitleKey : @"state",
                    kJMValueKey : scheduleLookup.state.value ?: @"-"
            },
            @{
                    kJMTitleKey : @"previousFireTime",
                    kJMValueKey : [self dateStringFromDate:scheduleLookup.state.previousFireTime] ?: @"-"
            },
            @{
                    kJMTitleKey : @"nextFireTime",
                    kJMValueKey : [self dateStringFromDate:scheduleLookup.state.nextFireTime] ?: @"-"
            }
    ];
    return resourceProperties;
}

- (void)deleteSchedule
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JSScheduleLookup *scheduleLookup = [self scheduleLookup];
    if (!scheduleLookup) {
        NSString *reason = @"ScheduleLookup is absent";
        NSException* wrongActionxception = [NSException exceptionWithName:@"ScheduleInfoViewException"
                                                                   reason:reason
                                                                 userInfo:nil];
        @throw wrongActionxception;
    }

    [self startShowLoaderWithMessage:@"status.loading"];
    __weak __typeof(self) weakSelf = self;
    [[JMScheduleManager sharedManager] deleteScheduleWithJobIdentifier:scheduleLookup.jobIdentifier
                                                            completion:^(NSError *error) {
                                                                __typeof(self) strongSelf = weakSelf;
                                                                [strongSelf stopShowLoader];
                                                                if (self.exitBlock) {
                                                                    self.exitBlock();
                                                                }
                                                                [strongSelf.navigationController popViewControllerAnimated:YES];
                                                            }];
}

- (void)editSchedule
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JSScheduleLookup *scheduleLookup = [self scheduleLookup];
    if (!scheduleLookup) {
        NSString *reason = @"ScheduleLookup is absent";
        NSException* wrongActionxception = [NSException exceptionWithName:@"ScheduleInfoViewException"
                                                                   reason:reason
                                                                 userInfo:nil];
        @throw wrongActionxception;
    }

    [self startShowLoaderWithMessage:@"status.loading"];
    __weak __typeof(self) weakSelf = self;
    [[JMScheduleManager sharedManager] loadScheduleMetadataForScheduleWithId:scheduleLookup.jobIdentifier completion:^(JSScheduleMetadata *metadata, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf stopShowLoader];
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

#pragma mark - Helpers

- (JSScheduleLookup *)scheduleLookup
{
    if (![self.resource isKindOfClass:[JMSchedule class]]) {
        return nil;
    }
    JMSchedule *schedule = (JMSchedule *) self.resource;
    return schedule.scheduleLookup;
}

- (NSString *)dateStringFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[JSDateFormatterFactory sharedFactory] formatterWithPattern:@"yyyy-MM-dd HH:mm"];
    // need set local timezone because of received value
    formatter.timeZone = [NSTimeZone localTimeZone];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

#pragma mark - Loaders

- (void)startShowLoaderWithMessage:(NSString *)message
{
    [JMUtils showNetworkActivityIndicator];
    [JMCancelRequestPopup presentWithMessage:message];
}

- (void)stopShowLoader
{
    [JMUtils hideNetworkActivityIndicator];
    [JMCancelRequestPopup dismiss];
}

@end