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


static JMCancelRequestPopup *instance;

@interface JMCancelRequestPopup ()
@property (nonatomic, strong) NSMutableArray *restClients;
@property (nonatomic, strong) NSMutableArray *cancelBlocks;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@end

@implementation JMCancelRequestPopup

#pragma mark - Class Methods

+ (void)presentWithMessage:(NSString *)message restClient:(JSRESTBase *)client cancelBlock:(JMCancelRequestBlock)cancelBlock {
    if (!instance) {
        instance = [[JMCancelRequestPopup alloc] initWithDelegate:nil type:JMPopupViewType_ContentViewOnly];
        UIView *nibView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
        instance.contentView = nibView;
    }
    instance.progressLabel.text = JMCustomLocalizedString(message, nil);
    [instance.cancelButton setTitle:JMCustomLocalizedString(@"dialog.button.cancel", nil) forState:UIControlStateNormal];
    if (client) {
        [instance.restClients addObject:client];
    }
    if (cancelBlock) {
        [instance.cancelBlocks addObject:[cancelBlock copy]];
    }
    [instance show];
}

- (void)showFromPoint:(CGPoint)point onView:(UIView *)view
{
    [JMUtils showNetworkActivityIndicator];
    [super showFromPoint:point onView:view];
}

- (void)dismiss:(BOOL)animated
{
    [self.restClients removeAllObjects];
    [self.cancelBlocks removeAllObjects];
    [super dismiss:animated];
}

#pragma mark - Actions
- (IBAction)cancelRequests:(id)sender
{
    for (JSRESTBase *restClient in self.restClients) {
        [restClient cancelAllRequests];
    }

    [JMRequestDelegate clearRequestPool];
    [JMUtils hideNetworkActivityIndicator];
    
    for (JMCancelRequestBlock block in self.cancelBlocks) {
        block();
    }
    
    [self dismiss];
}

+ (void) dismiss
{
    [instance dismiss:YES];
}

@end
