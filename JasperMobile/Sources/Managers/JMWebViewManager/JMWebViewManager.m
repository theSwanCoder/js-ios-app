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
//  JMWebViewManager.h
//  TIBCO JasperMobile
//

#import "JMWebViewManager.h"
#import "JMUtils.h"

@interface JMWebViewManager()
@property (nonatomic, strong, readwrite) UIWebView *webView;
@end

@implementation JMWebViewManager

+ (instancetype)sharedInstance {
    static JMWebViewManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.scrollView.bounces = NO;
        _webView.scalesPageToFit = YES;
        _webView.dataDetectorTypes = UIDataDetectorTypeNone;
        _webView.suppressesIncrementalRendering = YES;
    }
    return _webView;
}

- (UIWebView *)webViewWithParentFrame:(CGRect)frame
{
    if ([JMUtils isSystemVersion7]) {
        UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
        CGRect webViewFrame = CGRectZero;
        if ( UIInterfaceOrientationIsPortrait(statusBarOrientation) ) {
            webViewFrame = frame;
        } else {
            webViewFrame = CGRectMake(0, 0, CGRectGetHeight(frame), CGRectGetWidth(frame));
        }

        self.webView.frame = webViewFrame;
    } else {
        self.webView.frame = frame;
    }
    return self.webView;
}

- (void)reset
{
    self.webView = nil;
}

@end
