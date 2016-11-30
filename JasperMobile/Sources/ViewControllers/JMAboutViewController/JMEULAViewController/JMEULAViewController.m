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
//  JMEULAViewController.m
//  TIBCO JasperMobile
//

#import "JMEULAViewController.h"
#import "JMUtils.h"
#import "JMLocalization.h"

@interface JMEULAViewController() <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation JMEULAViewController

#pragma mark - LifeCycle
- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = JMLocalizedString(@"about_eula_title");

    if (self.shouldUserAccept) {
        UIBarButtonItem *acceptButton = [[UIBarButtonItem alloc] initWithTitle:JMLocalizedString(@"action_title_accept")
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(agreeAction:)];
        self.navigationItem.rightBarButtonItem = acceptButton;
    }

    NSString *path = [[NSBundle mainBundle] pathForResource:@"EULA" ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - Actions
- (IBAction)agreeAction:(id)sender
{
    if (self.completion) {
        self.completion();
    }
}

- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    JMLog(@"%@", NSStringFromSelector(_cmd));
    JMLog(@"request: %@", request);
    JMLog(@"navigationType: %@", @(navigationType));

    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}


@end
