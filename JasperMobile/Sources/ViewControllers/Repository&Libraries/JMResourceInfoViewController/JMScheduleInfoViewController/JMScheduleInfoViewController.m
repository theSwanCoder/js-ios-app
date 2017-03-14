/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMScheduleInfoViewController.h"
#import "JMResource.h"
#import "JMSchedule.h"
#import "JMScheduleManager.h"
#import "JMScheduleVC.h"
#import "JMConstants.h"
#import "JMUtils.h"
#import "UIAlertController+Additions.h"
#import "JMCancelRequestPopup.h"

@implementation JMScheduleInfoViewController

#pragma mark - Menu Actions
- (JMMenuActionsViewAction)availableAction
{
    JMMenuActionsViewAction action = [super availableAction];
    action |= JMMenuActionsViewAction_Edit;
    action |= JMMenuActionsViewAction_Delete;
    return action;
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
- (NSArray *)resourceProperties
{
    JSScheduleLookup *scheduleLookup = [self scheduleLookup];
    if (!scheduleLookup) {
        return nil;
    }
    NSMutableArray *resourceProperties = [@[
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
                    kJMTitleKey : @"schedule_owner",
                    kJMValueKey : scheduleLookup.owner ?: @"-"
            },
            @{
                    kJMTitleKey : @"schedule_state",
                    kJMValueKey : scheduleLookup.state.value ?: @"-"
            },
            @{
                    kJMTitleKey : @"schedule_previousFireTime",
                    kJMValueKey : [self dateStringFromDate:scheduleLookup.state.previousFireTime] ?: @"-"
            }
    ] mutableCopy];
    NSString *nextFireTime = @"-";
    if (![[scheduleLookup.state.value lowercaseString] isEqualToString:@"paused"]) {
        nextFireTime = [self dateStringFromDate:scheduleLookup.state.nextFireTime] ?: @"-";;
    }
    [resourceProperties addObject: @{
                                     kJMTitleKey : @"schedule_nextFireTime",
                                     kJMValueKey : nextFireTime
                                     }];

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

    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod_title_confirmation"
                                                                                      message:@"savedreport_viewer_delete_confirmation_message"
                                                                            cancelButtonTitle:@"dialog_button_cancel"
                                                                      cancelCompletionHandler:nil];
    __weak typeof(self) weakSelf = self;
    [alertController addActionWithLocalizedTitle:@"dialog_button_ok"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
        __strong typeof(self) strongSelf = weakSelf;
        [self startShowLoaderWithMessage:@"status_loading"];
        __weak __typeof(self) weakSelf = strongSelf;
        [[JMScheduleManager sharedManager] deleteScheduleWithJobIdentifier:scheduleLookup.jobIdentifier
                                                                completion:^(NSError *error) {
                                                                    __typeof(self) strongSelf = weakSelf;
                                                                    [strongSelf stopShowLoader];
                                                                    if (self.exitBlock) {
                                                                        self.exitBlock();
                                                                    }
                                                                    [strongSelf.navigationController popViewControllerAnimated:YES];
                                                                }];
    }];
    [self presentViewController:alertController animated:YES completion:nil];
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

    [self startShowLoaderWithMessage:@"status_loading"];
    __weak __typeof(self) weakSelf = self;
    [[JMScheduleManager sharedManager] loadScheduleMetadataForScheduleWithId:scheduleLookup.jobIdentifier completion:^(JSScheduleMetadata *metadata, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf stopShowLoader];
        if (metadata) {
            JMScheduleVC *newScheduleVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMScheduleVC"];
            [newScheduleVC updateScheduleMetadata:metadata];
            newScheduleVC.exitBlock = ^(JSScheduleMetadata *scheduleMetadata) {
                if (self.exitBlock) {
                    self.exitBlock();
                }
#warning NEED RELOAD RESOURCE!!!
//                [self resetResourceProperties];
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
