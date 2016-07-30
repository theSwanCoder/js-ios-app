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
//  JMMenuViewController.h
//  TIBCO JasperMobile
//

#import <MessageUI/MessageUI.h>
#import "JMMenuViewController.h"
#import "SWRevealViewController.h"
#import "JMMenuItemTableViewCell.h"
#import "JMMainNavigationController.h"
#import "JMLibraryCollectionViewController.h"
#import "JMSavedItemsCollectionViewController.h"
#import "JMFavoritesCollectionViewController.h"
#import "JMAboutViewController.h"
#import "JMServerProfile.h"
#import "JMServerProfile+Helpers.h"
#import "JMConstants.h"
#import "JMServerOptionsViewController.h"
#import "JMAnalyticsManager.h"
#import "JMThemesManager.h"
#import "JMUtils.h"
#import "NSObject+Additions.h"
#import "JMLocalization.h"

typedef NS_ENUM(NSInteger, JMMenuButtonState) {
    JMMenuButtonStateNormal,
    JMMenuButtonStateNotification,
};

@interface JMMenuViewController() <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *organizationNameLabel;
@property (strong, nonatomic) NSArray *menuItems;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *separatorsCollection;

@end

@implementation JMMenuViewController
+ (NSInteger)defaultItemIndex {
    return JMSectionTypeLibrary;
}

#pragma mark - LifeCycle
-(void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(exportedResouceDidLoad:)
                                                 name:kJMExportedResourceDidLoadNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverProfileDidChange:)
                                                 name:JMServerProfileDidChangeNotification
                                               object:nil];
}

#pragma mark - UIViewController LifeCycle
-(void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [[JMThemesManager sharedManager] menuViewBackgroundColor];
    self.userNameLabel.textColor = [[JMThemesManager sharedManager] menuViewUserNameTextColor];
    self.serverNameLabel.textColor = [[JMThemesManager sharedManager] menuViewAdditionalInfoTextColor];
    self.organizationNameLabel.textColor = [[JMThemesManager sharedManager] menuViewAdditionalInfoTextColor];
    self.appVersionLabel.textColor = [[JMThemesManager sharedManager] menuViewAdditionalInfoTextColor];
    
    [self.separatorsCollection makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:[[JMThemesManager sharedManager] menuViewSeparatorColor]];

    // version and build
    NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    self.appVersionLabel.text = [NSString stringWithFormat:@"v. %@ (%@)", version, build];

    [self updateServerInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

#pragma mark - Public API
- (void)reset
{
    self.menuItems = nil;
    [self setSelectedItemIndex:[[self class] defaultItemIndex]];
    [self updateServerInfo];
    [self.tableView setContentOffset:CGPointZero];
}

#pragma mark - Utils
- (void)updateServerInfo
{
    NSString *alias = self.restClient.serverProfile.alias;
    NSString *version = self.restClient.serverProfile.serverInfo.version;
    self.serverNameLabel.text = [NSString stringWithFormat:@"%@ (v.%@)", alias, version];
    self.userNameLabel.text = self.restClient.serverProfile.username;
    self.organizationNameLabel.text = self.restClient.serverProfile.organization;
}

- (void)unselectItems
{
    for(JMMenuItem *item in self.menuItems) {
        if (item.selected) {
            item.selected = NO;
        }
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMMenuItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JMMenuItemTableViewCell"
                                                                    forIndexPath:indexPath];
    cell.menuItem = self.menuItems[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self setSelectedItemIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
    JMMenuItem *menuItem = self.menuItems[indexPath.row];
    cell.selected = menuItem.selected;
}

#pragma mark - Public API
- (void) setSelectedItemIndex:(NSUInteger)itemIndex
{
    if (itemIndex > self.menuItems.count) {
        return;
    }

    JMMenuItem *currentSelectedItem = self.selectedItem;
    JMMenuItem *item = self.menuItems[itemIndex];
    item.showNotes = NO;

    if (item.sectionType == JMSectionTypeLogout) {
        [[JMSessionManager sharedManager] logout];
        [JMUtils showLoginViewAnimated:YES completion:nil];
        self.menuItems = nil;
    } else if (item.sectionType == JMSectionTypeSettings) {
        [self closeMenu];

        JMServerOptionsViewController *settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:[item vcIdentifierForSelectedItem]];
        settingsVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:JMCustomLocalizedString(@"dialog_button_cancel", nil)
                                                                                        style:UIBarButtonItemStyleDone
                                                                                       target:settingsVC
                                                                                       action:@selector(cancel)];
        settingsVC.serverProfile = [JMUtils activeServerProfile];
        __weak __typeof(settingsVC) weakSettingVC = settingsVC;
        settingsVC.exitBlock = ^{
            __typeof(settingsVC) strongSettingVC = weakSettingVC;
            [strongSettingVC dismissViewControllerAnimated:YES completion:nil];
        };
        JMMainNavigationController *navController = [[JMMainNavigationController alloc] initWithRootViewController:settingsVC];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;

        [self.revealViewController.frontViewController presentViewController:navController
                                                                    animated:YES
                                                                  completion:nil];

    } else if (item.sectionType == JMSectionTypeAbout) {
        [self closeMenu];

        JMMainNavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:[item vcIdentifierForSelectedItem]];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;

        [self.revealViewController.frontViewController presentViewController:navController
                                                                    animated:YES
                                                                  completion:nil];
    } else if (item.sectionType == JMSectionTypeFeedback) {
        [self showFeedback];
    } else {
        if (!currentSelectedItem || currentSelectedItem != item) {
            [self unselectItems];
            item.selected = YES;

            [self.tableView reloadData];

            id nextVC;
            if([item vcIdentifierForSelectedItem]) {
                // Analytics
                [[JMAnalyticsManager sharedManager] sendAnalyticsEventWithInfo:@{
                        kJMAnalyticsCategoryKey : kJMAnalyticsRepositoryEventCategoryTitle,
                        kJMAnalyticsActionKey : kJMAnalyticsRepositoryEventActionOpen,
                        kJMAnalyticsLabelKey : [item nameForAnalytics]
                }];

                nextVC = [self.storyboard instantiateViewControllerWithIdentifier:[item vcIdentifierForSelectedItem]];
                UIBarButtonItem *bbi = [self barButtonItemForState:JMMenuButtonStateNormal];
                [nextVC topViewController].navigationItem.leftBarButtonItem = bbi;
                [[nextVC topViewController].view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
            } else {
                nextVC = [JMUtils launchScreenViewController];
            }
            self.revealViewController.frontViewController = nextVC;
        }
        [self.revealViewController setFrontViewPosition:FrontViewPositionLeft
                                               animated:YES];
    }
}

- (void)openCurrentSection
{
    if (self.selectedItem) {
        [self.revealViewController setFrontViewPosition:FrontViewPositionLeft
                                               animated:YES];
    } else {
        [self setSelectedItemIndex:[JMMenuViewController defaultItemIndex]];
    }
}

#pragma mark - Properties
- (NSArray *)menuItems
{
    if (!_menuItems) {
        _menuItems = [self createMenuItems];
    }
    return _menuItems;
}

- (JMMenuItem *)selectedItem
{
    for (JMMenuItem *menuItem in self.menuItems) {
        if (menuItem.selected) {
            return menuItem;
        }
    }
    return nil;
}

#pragma mark - Actions
- (void)menuButtonTapped:(id)sender
{
    [self.revealViewController.frontViewController.view endEditing:YES];
    [self.revealViewController revealToggle:sender];
    [self hideNoteInMenuButton];
}


#pragma mark - Helpers
- (NSArray *)createMenuItems
{
    NSMutableArray *menuItems = [@[
            [JMMenuItem menuItemWithSectionType:JMSectionTypeLibrary],
            [JMMenuItem menuItemWithSectionType:JMSectionTypeRepository],
            [JMMenuItem menuItemWithSectionType:JMSectionTypeSavedItems],
            [JMMenuItem menuItemWithSectionType:JMSectionTypeFavorites],
            [JMMenuItem menuItemWithSectionType:JMSectionTypeScheduling],
            [JMMenuItem menuItemWithSectionType:JMSectionTypeAbout],
            [JMMenuItem menuItemWithSectionType:JMSectionTypeSettings],
            [JMMenuItem menuItemWithSectionType:JMSectionTypeFeedback],
            [JMMenuItem menuItemWithSectionType:JMSectionTypeLogout]
    ] mutableCopy];

    if ([JMUtils isServerProEdition]) {
        NSUInteger indexOfRepository = [menuItems indexOfObject:[JMMenuItem menuItemWithSectionType:JMSectionTypeRepository]];
        [menuItems insertObject:[JMMenuItem menuItemWithSectionType:JMSectionTypeRecentViews] atIndex:indexOfRepository + 1];
    }

    return [menuItems copy];
}

- (void)closeMenu
{
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
}

- (UIBarButtonItem *)barButtonItemForState:(JMMenuButtonState)buttonState
{
    UIImage *menuButtonImage;
    switch (buttonState) {
        case JMMenuButtonStateNormal: {
            menuButtonImage = [UIImage imageNamed:@"menu_icon"];
            break;
        }
        case JMMenuButtonStateNotification: {
            menuButtonImage = [UIImage imageNamed:@"menu_icon_note"];
            break;
        }
    }

    CGRect buttonFrame = CGRectMake(0, 0, menuButtonImage.size.width, menuButtonImage.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button setImage:menuButtonImage forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(menuButtonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:button];

    return bbi;
}

- (void)showNoteInMenuButton
{
    UINavigationController *navController = (UINavigationController *) self.revealViewController.frontViewController;
    for (UIViewController *viewController in navController.viewControllers) {
        if ([viewController isKindOfClass:[JMBaseCollectionViewController class]]) {
            UIButton *button = (UIButton *) viewController.navigationItem.leftBarButtonItem.customView;
            [button setImage:[UIImage imageNamed:@"menu_icon_note"] forState:UIControlStateNormal];
        }
    }
}

- (void)hideNoteInMenuButton
{
    UINavigationController *navController = (UINavigationController *) self.revealViewController.frontViewController;
    for (UIViewController *viewController in navController.viewControllers) {
        if ([viewController isKindOfClass:[JMBaseCollectionViewController class]]) {
            UIButton *button = (UIButton *) viewController.navigationItem.leftBarButtonItem.customView;
            [button setImage:[UIImage imageNamed:@"menu_icon"] forState:UIControlStateNormal];
        }
    }
}

- (JMMenuItem *)menuItemWithType:(JMSectionType)sectionType
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sectionType == %@", @(sectionType)];
    return [self.menuItems filteredArrayUsingPredicate:predicate].firstObject;
}

#pragma mark - Feedback
- (void)showFeedback
{
#if !TARGET_IPHONE_SIMULATOR
    if ([MFMailComposeViewController canSendMail]) {
        // Email Subject
        NSString *emailTitle = @"JasperMobile (iOS)";
        // Email Content
        NSString *messageBody = [NSString stringWithFormat:@"Send from build version: %@", [JMUtils buildVersion]];
        // To address
        NSArray *toRecipents = @[kFeedbackPrimaryEmail, kFeedbackSecondaryEmail];

        MFMailComposeViewController *mc = [MFMailComposeViewController new];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];

        [self presentViewController:mc animated:YES completion:NULL];
    } else {
        NSString *errorMessage = JMCustomLocalizedString(@"settings_feedback_errorShowClient", nil);
        NSError *error = [NSError errorWithDomain:@"dialod_title_error" code:NSNotFound userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
        [JMUtils presentAlertControllerWithError:error completion:nil];
    }
#endif
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            JMLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            JMLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            JMLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            JMLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }

    [self dismissViewControllerAnimated:YES completion:NULL];

    [self closeMenu];
}

#pragma mark - Notifications
- (void)exportedResouceDidLoad:(NSNotification *)notification
{
    if (self.selectedItem.sectionType != JMSectionTypeSavedItems) {
        [self showNoteInMenuButton];
        JMMenuItem *savedItem = [self menuItemWithType:JMSectionTypeSavedItems];
        savedItem.showNotes = YES;
    }
}

- (void)serverProfileDidChange:(NSNotification *)notification
{
    [self updateServerInfo];
}

@end
