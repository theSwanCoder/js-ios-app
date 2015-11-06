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
    return JMResourceTypeLibrary;
}

#pragma mark - LifeCycle
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateServerInfo];

    [self.tableView reloadData];
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
    if (itemIndex < self.menuItems.count) {
        JMMenuItem *currentSelectedItem = self.selectedItem;
        JMMenuItem *item = self.menuItems[itemIndex];
        
        if (item.resourceType == JMResourceTypeLogout) {
            [[JMSessionManager sharedManager] logout];
            [JMUtils showLoginViewAnimated:YES completion:nil];
            self.menuItems = nil;
        } else if (item.resourceType == JMResourceTypeAbout) {
            [self closeMenu];

            JMAboutViewController *aboutViewController = (JMAboutViewController *) [self.storyboard instantiateViewControllerWithIdentifier:[item vcIdentifierForSelectedItem]];
            aboutViewController.modalPresentationStyle = UIModalPresentationFormSheet;

            [self.revealViewController.frontViewController presentViewController:aboutViewController
                                                                        animated:YES
                                                                      completion:nil];
        } else if (item.resourceType == JMResourceTypeFeedback) {
            [self showFeedback];
        } else {
            if (!currentSelectedItem || currentSelectedItem != item) {
                [self unselectItems];
                item.selected = YES;

                [self.tableView reloadData];

                id nextVC;
                if([item vcIdentifierForSelectedItem]) {
                    // Analytics
                    [JMUtils logEventWithName:@"User opened section"
                                 additionInfo:@{
                                         @"Section's Name" : [item nameForCrashlytics]
                                 }];

                    nextVC = [self.storyboard instantiateViewControllerWithIdentifier:[item vcIdentifierForSelectedItem]];
                    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonTapped:)];
                    [nextVC topViewController].navigationItem.leftBarButtonItem = menuItem;
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
}


#pragma mark - Helpers
- (NSArray *)createMenuItems
{
    NSMutableArray *menuItems = [@[
            [JMMenuItem menuItemWithResourceType:JMResourceTypeLibrary],
            [JMMenuItem menuItemWithResourceType:JMResourceTypeRepository],
            [JMMenuItem menuItemWithResourceType:JMResourceTypeSavedItems],
            [JMMenuItem menuItemWithResourceType:JMResourceTypeFavorites],
            [JMMenuItem menuItemWithResourceType:JMResourceTypeAbout],
            [JMMenuItem menuItemWithResourceType:JMResourceTypeFeedback],
            [JMMenuItem menuItemWithResourceType:JMResourceTypeLogout]
    ] mutableCopy];

    if ([JMUtils isServerProEdition]) {
        NSUInteger indexOfRepository = [menuItems indexOfObject:[JMMenuItem menuItemWithResourceType:JMResourceTypeRepository]];
        [menuItems insertObject:[JMMenuItem menuItemWithResourceType:JMResourceTypeRecentViews] atIndex:indexOfRepository + 1];
    }

    return [menuItems copy];
}

- (void)closeMenu
{
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
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
        NSString *errorMessage = JMCustomLocalizedString(@"settings.feedback.errorShowClient", nil);
        NSError *error = [NSError errorWithDomain:@"dialod.title.error" code:NSNotFound userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
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

@end
