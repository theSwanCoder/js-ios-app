/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
//  JMReportPageViewerViewController.h
//  TIBCO JasperMobile
//

#import "JMReportPageViewerViewController.h"

@interface JMReportPageViewerViewController() <UIWebViewDelegate>
@property (nonatomic, assign, getter=isStartLoad) BOOL startLoad;
@end

@implementation JMReportPageViewerViewController

#pragma mark - Lifecycle
-(void)dealloc
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSLog(@"page: %@", @(self.pageIndex));
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.startLoad = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isStartLoad) {
        [self startShowLoadProgress];
    }
}

#pragma mark - Public API
- (void)startShowLoadProgress
{
    [JMUtils showNetworkActivityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)stopShowLoadProgress
{
    [JMUtils hideNetworkActivityIndicator];
    [self.activityIndicator stopAnimating];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // TODO: start load indicator?
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopShowLoadProgress];
}

@end
