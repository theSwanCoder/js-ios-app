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
@property (weak, nonatomic) WKWebView *contentWebView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHightConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) CGFloat contentViewProportions;
@property (nonatomic, assign) CGSize originalWebViewSize;
@end

@implementation JMExternalWindowControlsVC

#pragma mark - Object LifeCycle
- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (instancetype)initWithContentWebView:(WKWebView *)contentView
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

    [self updateInterface];
}

- (void)viewDidLayoutSubviews
{

    [self layoutControlView];

    [super viewDidLayoutSubviews];
}

#pragma mark - Public API
- (void)updateInterface
{
    [self starShowingProgress];
    [self createContentScreenshotWithCompletion:^(UIImage *screenshotImage) {
        [self endShowingProgress];

        [self setupControlViewWithImage:screenshotImage];
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y *= self.contentViewProportions;
    self.contentWebView.scrollView.contentOffset = contentOffset;
}


#pragma mark - Helpers
- (void)createContentScreenshotWithCompletion:(void(^)(UIImage *screenshotImage))completion
{
    if (!completion) {
        return;
    }

    self.originalWebViewSize = self.contentWebView.frame.size;
    CGSize contentSize = self.contentWebView.scrollView.contentSize;
    self.contentWebView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

        UIGraphicsBeginImageContextWithOptions(contentSize, NO, 0);
        [self.contentWebView.scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];

        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        dispatch_async(dispatch_get_main_queue(), ^(void){
            CGRect conentWebViewFrame = CGRectMake(0, 0, self.originalWebViewSize.width, self.originalWebViewSize.height);
            self.contentWebView.frame = conentWebViewFrame;

            completion(viewImage);
        });
    });
}

- (void)setupControlViewWithImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (void)layoutControlView
{
    CGFloat contentWidth = self.contentWebView.scrollView.contentSize.width;
    CGFloat contentHeight = self.contentWebView.scrollView.contentSize.height;

    CGFloat k = contentWidth / contentHeight;

    // Calculate control scroll view size
    CGFloat controlViewContentWidth = self.scrollView.contentSize.width;
    CGFloat controlViewContentHeight = self.scrollView.contentSize.width / k;
    CGSize controlViewSize = CGSizeMake(controlViewContentWidth, controlViewContentHeight);
    self.scrollView.contentSize = controlViewSize;

    self.imageViewHightConstraint.constant = controlViewContentHeight;
    self.contentViewProportions = contentHeight / controlViewContentHeight;
}

#pragma mark - Progress indicators
- (void)starShowingProgress
{
    [self.activityIndicator startAnimating];
    self.imageView.hidden = YES;
}

- (void)endShowingProgress
{
    [self.activityIndicator stopAnimating];
    self.imageView.hidden = NO;
}

@end
