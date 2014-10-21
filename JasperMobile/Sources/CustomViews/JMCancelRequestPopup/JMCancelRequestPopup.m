/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JMCancelRequestPopup.m
//  TIBCO JasperMobile
//

#import "JMCancelRequestPopup.h"
#import "JMUtils.h"
#import "UIViewController+MJPopupViewController.h"
#import "JMRequestDelegate.h"
#import <QuartzCore/QuartzCore.h>

static JMCancelRequestPopup *instance;
static CGPoint popupOffset;

@interface JMCancelRequestPopup ()
@property (nonatomic, strong) JSRESTBase *restClient;
@property (nonatomic, copy) JMCancelRequestBlock cancelBlock;
@property (nonatomic, weak) UIViewController *delegate;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@end

@implementation JMCancelRequestPopup

#pragma mark - Class Methods

+ (void)presentInViewController:(UIViewController *)viewController message:(NSString *)message restClient:(JSRESTBase *)client cancelBlock:(JMCancelRequestBlock)cancelBlock
{
    if (!instance) {
        instance = [[JMCancelRequestPopup alloc] initWithNibName:@"JMCancelRequestPopup" bundle:nil];
        instance.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [viewController presentPopupViewController:instance animationType:MJPopupViewAnimationFade];
        instance.view.layer.borderColor = [UIColor whiteColor].CGColor;
        instance.view.layer.borderWidth = 1;
    }
    instance.restClient = client;
    instance.delegate = viewController;
    instance.cancelBlock = cancelBlock;
    instance.progressLabel.text = JMCustomLocalizedString(message, nil);
    [instance.cancelButton setTitle:JMCustomLocalizedString(@"dialog.button.cancel", nil) forState:UIControlStateNormal];

    [self applyOffset];
}

+ (void)offset:(CGPoint)offset
{
    popupOffset = offset;
    if (instance != nil) {
        [self applyOffset];
    }
}

+ (void)dismiss
{
    [JMUtils hideNetworkActivityIndicator];
    [instance.delegate dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    instance = nil;
}

+ (BOOL)isVisiblePopup
{
    return !!instance;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.layer.cornerRadius = 5.0f;
}

#pragma mark - Actions

- (IBAction)cancelRequests:(id)sender
{
    [self.restClient cancelAllRequests];
    [JMRequestDelegate clearRequestPool];
    [self.delegate dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    
    [JMCancelRequestPopup dismiss];
}

#pragma mark - NSObject

- (void)dealloc
{
    self.view = nil;
}

#pragma mark - Private

+ (void)applyOffset
{
    if (!CGPointEqualToPoint(popupOffset, CGPointZero)) {
        CGRect frame = instance.view.frame;
        CGRect frameWithOffset = CGRectMake(frame.origin.x + popupOffset.x, frame.origin.y + popupOffset.y, frame.size.width, frame.size.height);
        instance.view.frame = frameWithOffset;
    }
}

@end
