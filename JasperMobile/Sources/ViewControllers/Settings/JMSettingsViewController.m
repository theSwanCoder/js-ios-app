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


#import "JMSettingsViewController.h"
#import "UITableViewCell+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import "JMSettingsTableViewCell.h"
#import "JMSettings.h"
#import "JMServerProfile+Helpers.h"
#import "JMPopupView.h"

#import "JMAppUpdater.h"
#import "UIView+Additions.h"
#import <MessageUI/MessageUI.h>
#import "ALToastView.h"
#import "JMOnboardIntroViewController.h"
#import "JMEULAViewController.h"

static NSString const *kFeedbackPrimaryEmail = @"js-dev-mobile@tibco.com";
static NSString const *kFeedbackSecondaryEmail = @"js.testdevice@gmail.com";

@interface JMSettingsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyButton;

@property (nonatomic, strong) JMSettings *detailSettings;
@end

@implementation JMSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = JMCustomLocalizedString(@"settings.title", nil);

    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    self.tableView.layer.cornerRadius = 4;

    [self.privacyPolicyButton setTitle:JMCustomLocalizedString(@"settings.privacy.policy.title", nil) forState:UIControlStateNormal];

    [self.saveButton setTitle:JMCustomLocalizedString(@"dialog.button.save", nil) forState:UIControlStateNormal];

    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info_item"] style:UIBarButtonItemStyleBordered target:self action:@selector(applicationInfo:)];
    self.navigationItem.rightBarButtonItem = infoItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshDataSource];
}

#pragma mark - Auto rotate
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([self isMenuShown]) {
       [self closeMenu];
    }
}

#pragma mark - Menu Utils
- (BOOL)isMenuShown
{
    return (self.revealViewController.frontViewPosition == FrontViewPositionRight);
}

- (void)closeMenu
{
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft];
}

- (void) refreshDataSource
{
    self.detailSettings = [[JMSettings alloc] init];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.detailSettings.itemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMSettingsItem *currentItem = self.detailSettings.itemsArray[indexPath.row];
    JMSettingsTableViewCell *cell = (JMSettingsTableViewCell *) [tableView dequeueReusableCellWithIdentifier:currentItem.cellIdentifier];
    [cell setBottomSeparatorWithHeight:1 color:self.view.backgroundColor tableViewStyle:tableView.style];
    cell.settingsItem = currentItem;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JMSettingsItem *currentItem = self.detailSettings.itemsArray[indexPath.row];

    if ([currentItem.cellIdentifier isEqualToString:kJMLabelCellIdentifier]) {
        NSInteger value = ((NSNumber *)currentItem.valueSettings).integerValue;

        if (value == kJMPrivacyPolicySettingValue) {
            [self showPrivacyPolicy];
        } else if (value == kJMOnboardIntroSettingValue) {
            [self showOnboardIntro];
        } else if (value == kJMFeedbackSettingValue) {
            [self sendFeedback];
        } else if (value == kJMEULASettingValue) {
            [self showEULA];
        }
    }
}

#pragma mark - Feedback by email
- (void)sendFeedback
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
        [self showErrorWithMessage:@"settings.feedback.errorShowClient"];
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
}

- (void)showErrorWithMessage:(NSString *)errorMessage
{
    [[UIAlertView localizedAlertWithTitle:@"dialod.title.error"
                                  message:errorMessage
                                 delegate:self
                        cancelButtonTitle:@"dialog.button.ok"
                        otherButtonTitles: nil] show];
}

#pragma mark - Actions
- (IBAction)saveButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    [ALToastView toastInView:self.tableView
                    withText:JMCustomLocalizedString(@"settings.save.message", nil)];
    
    BOOL previousSendingCrashReports = [JMUtils crashReportsSendingEnable];
    [self.detailSettings saveSettings];
    
    if (previousSendingCrashReports != [JMUtils crashReportsSendingEnable]) {
        [[UIAlertView localizedAlertWithTitle:@"settings.crashtracking.alert.title"
                                      message:@"settings.crashtracking.alert.message"
                                     delegate:self
                            cancelButtonTitle:@"dialog.button.ok"
                            otherButtonTitles: nil] show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)applicationInfo:(id)sender
{
    NSString *appName;
    appName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
    NSInteger currentYear = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]] year];
    NSString *message = [NSString stringWithFormat:JMCustomLocalizedString(@"application.info", nil), appName, [JMAppUpdater latestAppVersionAsString], [JMServerProfile minSupportedServerVersion], currentYear];

    [[UIAlertView localizedAlertWithTitle:nil
                                  message:message
                                 delegate:nil
                        cancelButtonTitle:@"dialog.button.ok"
                        otherButtonTitles:nil] show];
}

- (void)showPrivacyPolicy
{
    [self performSegueWithIdentifier:@"showPrivacyPolicy" sender:self];
    if ([self isMenuShown]) {
        [self closeMenu];
    }
}

- (void)showOnboardIntro
{
    JMOnboardIntroViewController *introViewController = (JMOnboardIntroViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"JMOnboardIntroViewController"];
    [self presentViewController:introViewController animated:YES completion:nil];
    if ([self isMenuShown]) {
        [self closeMenu];
    }
}

- (void)showEULA
{
    JMEULAViewController *EULAViewController = (JMEULAViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"JMEULAViewController"];
    EULAViewController.completion = nil;
    EULAViewController.shouldUserAccept = NO;

    [self.navigationController pushViewController:EULAViewController
                                         animated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
