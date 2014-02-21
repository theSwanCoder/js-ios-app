/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2014 Jaspersoft Corporation. All rights reserved.
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
//  JMSavedReportViewerViewController.m
//  Jaspersoft Corporation
//

#import "JMSavedReportViewerViewController.h"
#import "JMUtils.h"

@implementation JMSavedReportViewerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TODO: remove after iOS 5/6 drop
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        [self adjustWebView];
    }
    
    NSURL *reportPath = [NSURL fileURLWithPath:self.reportPath];
    [self.webView loadRequest:[NSURLRequest requestWithURL:reportPath]];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        [self adjustWebView];
    }
}

#pragma mark - Private

- (void)adjustWebView
{
    CGRect navigationBarFrame = self.navigationController.navigationBar.frame;
    CGRect webViewFrame = self.webView.frame;
    webViewFrame.origin.y = navigationBarFrame.origin.y + navigationBarFrame.size.height + 2.5f;
    self.webView.frame = webViewFrame;
}

@end
