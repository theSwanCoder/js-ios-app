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
#import <QuartzCore/QuartzCore.h>
#import "JMServerProfile+Helpers.h"
#import "JMPopupView.h"

#import "JMAppUpdater.h"
#import "UIView+Additions.h"
#import <MessageUI/MessageUI.h>
#import "ALToastView.h"
#import "JMOnboardIntroViewController.h"
#import "JMEULAViewController.h"
#import "UIColor+RGBComponent.h"

NSString * const kJMCommunitySiteURL = @"http://community.jaspersoft.com/project/jaspermobile-ios";
NSString * const kJMWhatsNewURL = @"https://github.com/Jaspersoft/js-ios-app/wiki/What's-new";
NSString * const kJMCommunitySiteInternalLink = @"community_site";
NSString * const kJMPrivacyPolicyInternalLink = @"privacy_policy";
NSString * const kJMEULAInternalLink = @"eula";
NSString * const kJMWhatsNewInternalLink = @"whats_new";

@interface JMAboutViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *aboutAppTextView;
@end

@implementation JMAboutViewController

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = JMCustomLocalizedString(@"menuitem_about_label", nil);
    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    [self setupTextView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(closeAboutAction:)];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [self.aboutAppTextView sizeToFit];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    BOOL shouldInteract = YES;
    if ([URL.absoluteString isEqualToString:kJMCommunitySiteInternalLink]) {
        [self showCommunitySite];
    } else if ([URL.absoluteString isEqualToString:kJMPrivacyPolicyInternalLink]) {
        [self showPrivacyPolicy];
    } else if ([URL.absoluteString isEqualToString:kJMEULAInternalLink]) {
        [self showEULA];
    }  else if ([URL.absoluteString isEqualToString:kJMWhatsNewInternalLink]) {
        [self showWhatsNew];
    } else {
        shouldInteract = NO;
    }
    return shouldInteract;
}

#pragma mark - Actions
- (void)closeAboutAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Actions
- (void)showPrivacyPolicy
{
    NSURL *url = [NSURL URLWithString:kJMPrivacyPolicyURI];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)showCommunitySite
{
    NSURL *url = [NSURL URLWithString:kJMCommunitySiteURL];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)showEULA
{
    UINavigationController *EULANavViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EULANavViewController"];
    [self presentViewController:EULANavViewController animated:YES completion:nil];
}

- (void)showWhatsNew
{
    NSURL *url = [NSURL URLWithString:kJMWhatsNewURL];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Helpers
- (void)setupTextView
{
    NSMutableAttributedString *aboutString = [[NSMutableAttributedString alloc] initWithAttributedString:[self appName]];
    [aboutString appendAttributedString:[self appAbout]];
//    [aboutString appendAttributedString:[self appVersion]];
    [aboutString appendAttributedString:[self privacyPolicy]];
    [aboutString appendAttributedString:[self eula]];
    [aboutString appendAttributedString:[self whatsNew]];
    [aboutString appendAttributedString:[self copyright]];

    [self setupLinksForString:aboutString];

    self.aboutAppTextView.attributedText = aboutString;
}

- (void)setupLinksForString:(NSMutableAttributedString *)attributedString
{
    NSDictionary *attributes = @{
            NSForegroundColorAttributeName : [UIColor colorFromHexString:[NSString stringWithFormat:@"#007aff"]],
            NSUnderlineStyleAttributeName: @1
    };

    // Community Site
    NSRange range = [attributedString.string rangeOfString:JMCustomLocalizedString(@"about_comminity_title", nil)];
    [attributedString addAttributes:attributes range:range];
    [attributedString addAttribute:NSLinkAttributeName
                        value:kJMCommunitySiteInternalLink
                        range:range];

    // Privacy Policy
    range = [attributedString.string rangeOfString:JMCustomLocalizedString(@"about_privacy_policy_title", nil)];
    [attributedString addAttributes:attributes range:range];
    [attributedString addAttribute:NSLinkAttributeName
                        value:kJMPrivacyPolicyInternalLink
                        range:range];

    // EULA
    range = [attributedString.string rangeOfString:JMCustomLocalizedString(@"about_eula_title", nil)];
    [attributedString addAttributes:attributes range:range];
    [attributedString addAttribute:NSLinkAttributeName
                        value:kJMEULAInternalLink
                        range:range];

    // What's New
    range = [attributedString.string rangeOfString:JMCustomLocalizedString(@"about_whats_new_title", nil)];
    [attributedString addAttributes:attributes range:range];
    [attributedString addAttribute:NSLinkAttributeName
                             value:kJMWhatsNewInternalLink
                             range:range];
}

#pragma mark - Generating attributed strings
- (NSAttributedString *)appName
{
    NSString *appNameString = kJMAppName;
    return [self createAttributedStringWithString:appNameString
                                       attributes:[self titleAttributes]];
}

- (NSAttributedString *)appAbout
{
    NSString *build = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    NSString *appVersionString = [NSString stringWithFormat:@"Version: %@ (%@)", [JMAppUpdater latestAppVersionAsString], build];
    CGFloat minVersion = [JSUtils minSupportedServerVersion];
    NSString *comminityTitle = JMCustomLocalizedString(@"about_comminity_title", nil);
    NSString *appAboutString = [NSString stringWithFormat:JMCustomLocalizedString(@"application_info", nil),
                    minVersion,
                    appVersionString,
                    comminityTitle];
    return [self createAttributedStringWithString:[NSString stringWithFormat:@"\n\n%@", appAboutString]
                                       attributes:[self commonAttributes]];
}

- (NSAttributedString *)copyright
{
    NSInteger currentYear = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]] year];
    NSString *copyrightString = [NSString stringWithFormat:JMCustomLocalizedString(@"about_copyright", nil), currentYear];
    return [self createAttributedStringWithString:[NSString stringWithFormat:@"\n\n\n%@", copyrightString]
                                       attributes:[self commonAttributes]];
}

- (NSAttributedString *)privacyPolicy
{
    NSString *privacyPolicyString = JMCustomLocalizedString(@"about_privacy_policy_title", nil);
    return [self createAttributedStringWithString:[NSString stringWithFormat:@"\n\n%@", privacyPolicyString]
                                       attributes:[self commonAttributes]];
}

- (NSAttributedString *)eula
{
    NSString *eulaString = JMCustomLocalizedString(@"about_eula_title", nil);
    return [self createAttributedStringWithString:[NSString stringWithFormat:@"\n\n%@", eulaString]
                                       attributes:[self commonAttributes]];
}

- (NSAttributedString *)whatsNew
{
    NSString *whatsNewString = JMCustomLocalizedString(@"about_whats_new_title", nil);
    return [self createAttributedStringWithString:[NSString stringWithFormat:@"\n\n%@", whatsNewString]
                                       attributes:[self commonAttributes]];
}

#pragma mark - Helper for attributed strings
- (NSAttributedString *)createAttributedStringWithString:(NSString *)string attributes:(NSDictionary *)attributes
{
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string
                                                                           attributes:attributes];
    return attributedString;
}

- (NSDictionary *)commonAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.headIndent = 20;
    paragraphStyle.firstLineHeadIndent = 20;

    NSDictionary *attributes = @{
            NSFontAttributeName : [[JMThemesManager sharedManager] appAboutCommonTextFont],
            NSForegroundColorAttributeName : [[JMThemesManager sharedManager] aboutAppAppAboutTextColor],
            NSParagraphStyleAttributeName: paragraphStyle
    };

    return attributes;
}

- (NSDictionary *)titleAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new] ;
    paragraphStyle.alignment = NSTextAlignmentCenter;

    NSDictionary *attributes = @{
            NSFontAttributeName : [[JMThemesManager sharedManager] appAboutTitleFont],
            NSForegroundColorAttributeName : [[JMThemesManager sharedManager] aboutAppAppNameTextColor],
            NSParagraphStyleAttributeName: paragraphStyle
    };
    return attributes;
}

@end
