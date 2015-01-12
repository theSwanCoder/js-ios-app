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
#import "JMRequestDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>

@interface JMCancelRequestPopup ()
@property (nonatomic, strong) JSRESTBase *restClient;
@property (nonatomic, copy) JMCancelRequestBlock cancelBlock;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@end

@implementation JMCancelRequestPopup

#pragma mark - Class Methods

+ (void)presentWithMessage:(NSString *)message restClient:(JSRESTBase *)client cancelBlock:(JMCancelRequestBlock)cancelBlock {
    JMCancelRequestPopup *popup = (JMCancelRequestPopup *)[self displayedPopupViewForClass:[self class]];
    if (!popup) {
        popup = [[JMCancelRequestPopup alloc] initWithDelegate:nil type:JMPopupViewType_ContentViewOnly];
        UIView *nibView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:popup options:nil] lastObject];
        popup->_backGroundView.layer.cornerRadius = 5.f;
        popup->_backGroundView.layer.masksToBounds = YES;
        popup.contentView = nibView;
        [popup show];
    }
    popup.progressLabel.text = JMCustomLocalizedString(message, nil);
    [popup.cancelButton setTitle:JMCustomLocalizedString(@"dialog.button.cancel", nil) forState:UIControlStateNormal];
    popup.restClient = client;
    popup.cancelBlock = cancelBlock;
    [JMUtils showNetworkActivityIndicator];
}

- (void)dismiss:(BOOL)animated
{
    [super dismiss:animated];
    [JMUtils hideNetworkActivityIndicator];
}

#pragma mark - Actions
- (IBAction)cancelRequests:(id)sender
{
    [self.restClient cancelAllRequests];

    [JMRequestDelegate clearRequestPool];

    if (self.cancelBlock) {
        self.cancelBlock();
    }
    
    [self dismiss:YES];
}

+ (void) dismiss
{
    [JMPopupView dismissAllVisiblePopups:YES];
}

@end