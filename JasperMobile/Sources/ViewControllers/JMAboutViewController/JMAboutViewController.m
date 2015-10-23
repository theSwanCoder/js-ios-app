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

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsCollection;

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

    for (UIButton * button in self.buttonsCollection) {
        [button setBackgroundColor:[[JMThemesManager sharedManager] aboutAppButtonsBackgroundColor]];
        [button setTitleColor:[[JMThemesManager sharedManager] aboutAppButtonsTextColor] forState:UIControlStateNormal];
    }
    
    NSDictionary *appNameAttributes = @{
                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:[JMUtils isIphone] ? 16 : 25],
                                 NSForegroundColorAttributeName : [[JMThemesManager sharedManager] aboutAppAppNameTextColor]
                                 };

    NSString *appNameString = [NSString stringWithFormat:@"%@ v %@\n\n", kJMAppName, [JMAppUpdater latestAppVersionAsString]];
    NSAttributedString *appNameAttributedString = [[NSAttributedString alloc] initWithString:appNameString attributes:appNameAttributes];
    
    NSInteger currentYear = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]] year];
    NSString *appAboutString = [NSString stringWithFormat:JMCustomLocalizedString(@"application.info", nil),
                         @"\u00AE",
                         [JMServerProfile minSupportedServerVersion],
                         currentYear];
    
    NSDictionary *appAboutAttributes = @{
                                 NSFontAttributeName : [UIFont systemFontOfSize:[JMUtils isIphone] ? 14 : 20],
                                 NSForegroundColorAttributeName : [[JMThemesManager sharedManager] aboutAppAppAboutTextColor]
                                 };
    NSAttributedString *appAboutAttributedString = [[NSAttributedString alloc] initWithString:appAboutString attributes:appAboutAttributes];
    
    NSMutableAttributedString *aboutString = [[NSMutableAttributedString alloc] initWithAttributedString:appNameAttributedString];
    [aboutString appendAttributedString:appAboutAttributedString];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [aboutString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aboutString length])];
    
    self.aboutAppTextView.attributedText = aboutString;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interfaceOrientationDidChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];

}

#pragma mark - Auto rotate
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if ([self isMenuShown]) {
       [self closeMenu];
    }
}

- (void)interfaceOrientationDidChanged:(NSNotification *)notification
{
    CGSize size = [self.aboutAppTextView sizeThatFits:self.aboutAppTextView.bounds.size];
    
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
    if ([self isMenuShown]) {
        [self closeMenu];
    }
    JMEULAViewController *EULAViewController = (JMEULAViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"JMEULAViewController"];
    EULAViewController.completion = nil;
    EULAViewController.shouldUserAccept = NO;
    
    [self.navigationController pushViewController:EULAViewController animated:YES];
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
    return [[UIApplication sharedApplication] canOpenURL:URL];
}

- (void)showOnboardIntro
{
    JMOnboardIntroViewController *introViewController = (JMOnboardIntroViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"JMOnboardIntroViewController"];
    [self presentViewController:introViewController animated:YES completion:nil];
    if ([self isMenuShown]) {
        [self closeMenu];
    }
}

@end
