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
#import "JMMenuItemControllersFactory.h"
#import "ALToastView.h"
#import "JMScheduleManager.h"
#import "JMSchedule.h"
#import "JMScheduleVC.h"
#import "JMCancelRequestPopup.h"
#import "JMLibraryListLoader.h"
#import "JMLocalization.h"
#import "JMUtils.h"

@implementation JMSchedulesCollectionViewController

#pragma mark - LifeCycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.shouldShowButtonForChangingViewPresentation = NO;
    self.shouldShowRightNavigationItems = NO;
//    self.needLayoutUI = YES;

    [self addButtonForCreatingNewSchedule];
}

#pragma mark - Overloaded methods
- (BOOL)needShowSearchBar
{
    return [JMUtils isSupportSearchInSchedules];
}

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
    return JMLocalizedString(@"resources_noresults_schedules_msg");
}

- (Class)resourceLoaderClass
{
    return NSClassFromString(@"JMSchedulesListLoader");
}

- (void)actionForResource:(JMResource *)resource
{
    JMSchedule *schedule = (JMSchedule *) resource;
    [self startShowLoaderWithMessage:@"status_loading"];
    __weak __typeof(self) weakSelf = self;
    [[JMScheduleManager sharedManager] loadScheduleMetadataForScheduleWithId:schedule.scheduleLookup.jobIdentifier completion:^(JSScheduleMetadata *metadata, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf stopShowLoader];
        if (metadata) {
            JMScheduleVC *newScheduleVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"JMScheduleVC"];
            [newScheduleVC updateScheduleMetadata:metadata];
            newScheduleVC.exitBlock = ^(JSScheduleMetadata *scheduleMetadata) {
                [strongSelf.resourceListLoader setNeedsUpdate];
                [strongSelf.resourceListLoader updateIfNeeded];
            };
            [self.navigationController pushViewController:newScheduleVC animated:YES];
        } else {
            [JMUtils presentAlertControllerWithError:error
                                          completion:nil];
        }
    }];
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

#pragma mark - Helpers
- (void)addButtonForCreatingNewSchedule
{
    UIBarButtonItem *createScheduleButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                          target:self
                                                                                          action:@selector(createNewSchedule)];
    self.navigationItem.rightBarButtonItem = createScheduleButton;
}

#pragma mark - Actions
- (void)createNewSchedule
{
    JMMenuItem *menuItem = [JMMenuItem menuItemWithSectionType:JMSectionTypeLibrary];
    JMResourceCollectionViewController *libraryViewController = (JMResourceCollectionViewController *)[JMMenuItemControllersFactory viewControllerWithMenuItem:menuItem];
    libraryViewController.shouldShowButtonForChangingViewPresentation = NO;
    libraryViewController.shouldShowRightNavigationItems = NO;
    libraryViewController.navigationItem.leftBarButtonItem = nil;
    libraryViewController.resourceListLoader.filterBySelectedIndex = JMLibraryListLoaderFilterIndexByReport;
    __weak __typeof(self) weakSelf = self;
    libraryViewController.actionBlock = ^(JMResource *resource) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf scheduleReportWithResource:resource];
    };
    [self.navigationController pushViewController:libraryViewController animated:YES];
}

- (void)scheduleReportWithResource:(JMResource *)resource
{
    JMScheduleVC *newJobVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"JMScheduleVC"];
    [newJobVC createNewScheduleMetadataWithResourceLookup:resource];
    newJobVC.backButtonTitle = self.title;
    __weak __typeof(self) weakSelf = self;
    newJobVC.exitBlock = ^(JSScheduleMetadata *scheduleMetadata){
        __typeof(self) strongSelf = weakSelf;
        [strongSelf.resourceListLoader setNeedsUpdate];
        [strongSelf.resourceListLoader updateIfNeeded];
    };
    [UIView beginAnimations:nil context:nil];
    NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
    [controllers removeLastObject];
    [controllers addObject:newJobVC];
    self.navigationController.viewControllers = controllers;
    [UIView commitAnimations];
}


@end
