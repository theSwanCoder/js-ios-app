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
//  JMExternalWindowControlsVC.m
//  TIBCO JasperMobile
//

#import "JMExternalWindowControlsVC.h"

@interface JMExternalWindowControlsVC () <UIScrollViewDelegate>
@property (weak, nonatomic) UIWebView *contentWebView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHightConstraint;
@property (nonatomic, assign) CGFloat contentViewProportions;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation JMExternalWindowControlsVC

- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (instancetype)initWithContentWebView:(UIWebView *)contentView
{
    if (self = [super init]) {
        _contentWebView = contentView;
    }
    return self;
}

#pragma mark - UIViewController LifeCycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.contentWebView.frame = CGRectMake(0, 0, self.contentWebView.scrollView.contentSize.width, self.contentWebView.scrollView.contentSize.height);

    [self.activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        // Screenshot rendering from webView
        CGSize renderSize = self.contentWebView.scrollView.contentSize;
        UIGraphicsBeginImageContextWithOptions(renderSize, self.contentWebView.opaque, 0);
        [self.contentWebView.scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];

        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        // Resize Image View
        CGFloat k = self.contentWebView.scrollView.contentSize.width / self.contentWebView.scrollView.contentSize.height;

        renderSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetWidth(self.scrollView.frame) / k);
        UIGraphicsBeginImageContextWithOptions(renderSize, self.contentWebView.opaque, 0);
        CGRect rect = CGRectMake(0, 0, renderSize.width, renderSize.height);
        rect = CGRectIntegral(rect);
        [viewImage drawInRect:rect];
        viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self.activityIndicator stopAnimating];

            CGRect conentWebViewFrame = CGRectMake(0, 0, 1024, 768);
            self.contentWebView.frame = conentWebViewFrame;

            self.imageView.image = viewImage;

            CGSize size = CGSizeMake(viewImage.size.width, viewImage.size.height + 50);
            self.scrollView.contentSize = size;
            self.imageViewHightConstraint.constant = size.height;
            self.contentViewProportions = self.contentWebView.scrollView.contentSize.height / viewImage.size.height;
        });
    });

}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y *= self.contentViewProportions;
    self.contentWebView.scrollView.contentOffset = contentOffset;
}

@end
