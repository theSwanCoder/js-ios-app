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

CGFloat const kJMExternalWindowControlsScrollStep = 10;
CGFloat const kJMExternalWindowControlsScrollTimeInterval = 0.1;

@interface JMExternalWindowControlsVC () <UIScrollViewDelegate>
@property (weak, nonatomic) UIView *contentView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) CGFloat currentZoomScale;
@end

@implementation JMExternalWindowControlsVC

#pragma mark - Object LifeCycle
- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (instancetype)initWithContentView:(UIView *)contentView
{
    if (self = [super init]) {
        _contentView = contentView;
    }
    return self;
}

#pragma mark - UIViewController LifeCycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    WKWebView *contentView = (WKWebView *) self.contentView;
    self.currentZoomScale = contentView.scrollView.zoomScale;
}

#pragma mark - Actions Up
- (IBAction)upActionBegin:(id)sender
{
    [self startUpAction];
}

- (IBAction)upActionEnd:(id)sender
{
    [self stopAction];
}
#pragma mark - Actions Down
- (IBAction)downActionBegin:(id)sender
{
    [self startDownAction];
}

- (IBAction)downActionEnd:(id)sender
{
    [self stopAction];
}

#pragma mark - Actions Right
- (IBAction)rightActionEnd:(id)sender
{
    [self stopAction];
}

- (IBAction)rightActionBegin:(id)sender
{
    [self startRightAction];
}

#pragma mark - Actions Left
- (IBAction)leftActionEnd:(id)sender
{
    [self stopAction];
}

- (IBAction)leftActionBegin:(id)sender
{
    [self startLeftAction];
}

#pragma mark - Actions Zoom
- (IBAction)zoomUpAction:(id)sender
{
    WKWebView *contentView = (WKWebView *) self.contentView;
    CGFloat zoomScale = contentView.scrollView.zoomScale;
    zoomScale += 0.1;
    if (zoomScale >= 2 * self.currentZoomScale) {
        return;
    }
    [contentView.scrollView setZoomScale:zoomScale
                                animated:YES];
}

- (IBAction)zoomDownAction:(id)sender
{
    WKWebView *contentView = (WKWebView *) self.contentView;
    CGFloat zoomScale = contentView.scrollView.zoomScale;
    zoomScale -= 0.1;
    if (zoomScale <= self.currentZoomScale) {
        return;
    }
    [contentView.scrollView setZoomScale:zoomScale
                                animated:YES];
}


#pragma mark - Action Helpers Up
- (void)startUpAction
{
    if (self.timer) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kJMExternalWindowControlsScrollTimeInterval
                                                  target:self
                                                selector:@selector(upAction)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)upAction
{
    WKWebView *contentView = (WKWebView *) self.contentView;

    CGPoint upPoint = contentView.scrollView.contentOffset;
    upPoint.y += kJMExternalWindowControlsScrollStep;
    contentView.scrollView.contentOffset = upPoint;
}

#pragma mark - Action Helpers Down
- (void)startDownAction
{
    if (self.timer) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kJMExternalWindowControlsScrollTimeInterval
                                                  target:self
                                                selector:@selector(downAction)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)downAction
{
    WKWebView *contentView = (WKWebView *) self.contentView;

    CGPoint upPoint = contentView.scrollView.contentOffset;
    upPoint.y -= kJMExternalWindowControlsScrollStep;
    if (upPoint.y < 0) {
        return;
    }
    contentView.scrollView.contentOffset = upPoint;
}

#pragma mark - Action Helpers Left
- (void)startLeftAction
{
    if (self.timer) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kJMExternalWindowControlsScrollTimeInterval
                                                  target:self
                                                selector:@selector(leftAction)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)leftAction
{
    WKWebView *contentView = (WKWebView *) self.contentView;

    CGPoint upPoint = contentView.scrollView.contentOffset;
    upPoint.x += kJMExternalWindowControlsScrollStep;
    contentView.scrollView.contentOffset = upPoint;
}

#pragma mark - Action Helpers Right
- (void)startRightAction
{
    if (self.timer) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kJMExternalWindowControlsScrollTimeInterval
                                                  target:self
                                                selector:@selector(rightAction)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)rightAction
{
    WKWebView *contentView = (WKWebView *) self.contentView;

    CGPoint upPoint = contentView.scrollView.contentOffset;
    upPoint.x -= kJMExternalWindowControlsScrollStep;
    if (upPoint.x < 0) {
        return;
    }
    contentView.scrollView.contentOffset = upPoint;
}


- (void)stopAction
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
