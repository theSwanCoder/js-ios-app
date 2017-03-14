/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMCancelRequestPopup.h"
#import "JMUtils.h"
#import "JMLocalization.h"
#import <QuartzCore/QuartzCore.h>

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
        self.isAccessibilityElement = NO;
        self.accessibilityIdentifier = @"JMCancelRequestPopupAccessibilityId";
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
    popup.cancelButton.hidden = NO;
    [popup.cancelButton setTitle:JMLocalizedString(@"dialog_button_cancel") forState:UIControlStateNormal];
    popup.cancelBlock = cancelBlock;
}

+ (void)presentWithMessage:(NSString *)message
{
    JMCancelRequestPopup *popup;

    if (_cancelRequestPopupCounter++ == 0) { // there is no popup
        popup = [[JMCancelRequestPopup alloc] initWithDelegate:nil type:JMPopupViewType_ContentViewOnly];
        UIView *nibView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:popup options:nil] lastObject];
        popup->_backGroundView.layer.cornerRadius = 5.f;
        popup->_backGroundView.layer.masksToBounds = YES;
        popup.contentView = nibView;
        [popup show];
    } else { // there is popup
        popup = (JMCancelRequestPopup *)[self displayedPopupViewForClass:[self class]];
    }
    popup.progressLabel.text = JMLocalizedString(message);
    popup.cancelButton.hidden = YES;
    popup.cancelBlock = nil;
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
