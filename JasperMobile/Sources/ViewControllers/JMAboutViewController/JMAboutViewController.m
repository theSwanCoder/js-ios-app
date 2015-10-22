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


#import "JMAboutViewController.h"
#import "UITableViewCell+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import "JMServerProfile+Helpers.h"
#import "JMPopupView.h"

#import "JMAppUpdater.h"
#import "UIView+Additions.h"
#import <MessageUI/MessageUI.h>
#import "ALToastView.h"
#import "JMOnboardIntroViewController.h"
#import "JMEULAViewController.h"

@interface JMAboutViewController () <MFMailComposeViewControllerDelegate, UITextViewDelegate>


@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyButton;
@property (weak, nonatomic) IBOutlet UIButton *showEULAButton;
@property (weak, nonatomic) IBOutlet UIButton *sendFeedbackButton;

@property (weak, nonatomic) IBOutlet UITextView *aboutAppTextView;

@end

@implementation JMAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = JMCustomLocalizedString(@"menuitem.about.label", nil);

    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    
    [self.privacyPolicyButton setTitle:JMCustomLocalizedString(@"settings.privacy.policy.title", nil) forState:UIControlStateNormal];
    [self.showEULAButton setTitle:JMCustomLocalizedString(@"settings.privacy.EULA.title", nil) forState:UIControlStateNormal];
    [self.sendFeedbackButton setTitle:JMCustomLocalizedString(@"settings.feedback", nil) forState:UIControlStateNormal];

    NSString *appName;
    appName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
    NSInteger currentYear = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]] year];
    NSString *message = [NSString stringWithFormat:JMCustomLocalizedString(@"application.info", nil), appName, [JMAppUpdater latestAppVersionAsString], [JMServerProfile minSupportedServerVersion], currentYear];

    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont systemFontOfSize:[JMUtils isIphone] ? 15 : 20],
                                 NSForegroundColorAttributeName : [UIColor blackColor]
                                 };
    NSMutableAttributedString *aboutString = [[NSMutableAttributedString alloc] initWithString:message attributes:attributes];
    
//    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"www.google.com"];
//    NSDictionary *linkDic = @{ NSLinkAttributeName : [NSURL URLWithString:@"http://www.google.com"] };
//    [str setAttributes:linkDic range:[[str string] rangeOfString:@"www.google.com"]];
//    [aboutString appendAttributedString:str];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [aboutString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aboutString length])];
    
    self.aboutAppTextView.attributedText = aboutString;
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

#pragma mark - Actions
- (IBAction)privacyPolicyButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"showPrivacyPolicy" sender:self];
    if ([self isMenuShown]) {
        [self closeMenu];
    }
}

- (IBAction)showEULAButtonTapped:(id)sender
{
<<<<<<< HEAD:JasperMobile/Sources/ViewControllers/Settings/JMSettingsViewController.m
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
=======
    if ([self isMenuShown]) {
        [self closeMenu];
>>>>>>> Redesign and rename settings screen:JasperMobile/Sources/ViewControllers/JMAboutViewController/JMAboutViewController.m
    }
}

- (IBAction)sendFeedbackButtonTapped:(id)sender
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
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
<<<<<<< HEAD:JasperMobile/Sources/ViewControllers/Settings/JMSettingsViewController.m
    NSInteger currentYear = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]] year];
    NSString *message = [NSString stringWithFormat:JMCustomLocalizedString(@"application.info", nil),
                    kJMAppName,
                    [JMAppUpdater latestAppVersionAsString],
                    @"\u00AE",
                    [JMServerProfile minSupportedServerVersion],
                    currentYear];

    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:nil
                                                                                      message:message
                                                                            cancelButtonTitle:@"dialog.button.ok"
                                                                      cancelCompletionHandler:nil];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showPrivacyPolicy
{
    [self performSegueWithIdentifier:@"showPrivacyPolicy" sender:self];
    if ([self isMenuShown]) {
        [self closeMenu];
    }
=======
    return [[UIApplication sharedApplication] canOpenURL:URL];
>>>>>>> Redesign and rename settings screen:JasperMobile/Sources/ViewControllers/JMAboutViewController/JMAboutViewController.m
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
@end
