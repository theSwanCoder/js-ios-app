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
#import "JMLocalization.h"
#import <QuartzCore/QuartzCore.h>
#import "JMConstants.h"
#import "NSObject+Additions.h"

static NSInteger _cancelRequestPopupCounter = 0;

@interface JMCancelRequestPopup ()
@property (nonatomic, copy) JMCancelRequestBlock cancelBlock;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;

@end


@implementation JMCancelRequestPopup

#pragma mark - Class Methods

- (instancetype)initWithDelegate:(id<JMPopupViewDelegate>)delegate type:(JMPopupViewType)type
{
    self = [super initWithDelegate:delegate type:type];
    if (self) {
        self.isDissmissWithTapOutOfButton = NO;
        
        // Accessibility
        [self setAccessibility:NO withTextKey:nil identifier:JMCancelRequestPopupAccessibilityId];
    }
    return self;
}

+ (void)presentWithMessage:(NSString *)message cancelBlock:(JMCancelRequestBlock)cancelBlock
{
    JMCancelRequestPopup *popup;
    
    if (_cancelRequestPopupCounter++ == 0) { // there is no popup
        popup = [[JMCancelRequestPopup alloc] initWithDelegate:nil type:JMPopupViewType_ContentViewOnly];
        UIView *nibView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:popup options:nil] lastObject];
        nibView.backgroundColor = [UIColor clearColor];
        popup->_backGroundView.layer.cornerRadius = 5.f;
        popup->_backGroundView.layer.masksToBounds = YES;
        popup.contentView = nibView;
        [popup show];
    } else { // there is popup
        popup = (JMCancelRequestPopup *)[self displayedPopupViewForClass:[self class]];
    }
    popup.progressLabel.text = JMLocalizedString(message);

    if (cancelBlock) {
        popup.cancelButton.hidden = NO;
        [popup.cancelButton setTitle:JMLocalizedString(@"dialog_button_cancel") forState:UIControlStateNormal];
        popup.cancelBlock = cancelBlock;
    } else {
        popup.cancelButton.hidden = YES;
    }
}

+ (void)presentWithMessage:(NSString *)message
{
    [self presentWithMessage:message cancelBlock:nil];
}

- (void)dismiss:(BOOL)animated
{
    _cancelRequestPopupCounter --;
    if (_cancelRequestPopupCounter < 0) {
        _cancelRequestPopupCounter = 0;
    }
    if (_cancelRequestPopupCounter == 0) {
        [super dismiss:animated];
        [JMUtils hideNetworkActivityIndicator];
    }
}

#pragma mark - Actions
- (IBAction)cancelRequests:(id)sender
{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self dismiss:YES];
}

+ (void) dismiss
{
    JMCancelRequestPopup *cancelPopup = (JMCancelRequestPopup *)[self displayedPopupViewForClass:self];
    [cancelPopup dismiss];
}

@end
