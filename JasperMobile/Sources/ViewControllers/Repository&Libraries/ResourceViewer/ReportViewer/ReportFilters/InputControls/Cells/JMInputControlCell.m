/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMInputControlCell.h"
#import "JMThemesManager.h"

@interface JMInputControlCell()
@property (nonatomic, weak) IBOutlet UIView  *valuePlaceHolderView;
@end

@implementation JMInputControlCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.font = [[JMThemesManager sharedManager] tableViewCellTitleFont];
    self.titleLabel.textColor = [[JMThemesManager sharedManager] tableViewCellTitleTextColor];
    self.errorLabel.font = [[JMThemesManager sharedManager] tableViewCellErrorFont];
    self.errorLabel.textColor = [[JMThemesManager sharedManager] tableViewCellErrorColor];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
    self.errorLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.errorLabel.frame);
}

- (void) updateDisplayingOfErrorMessage
{
    NSString *errorString = [self.inputControlDescriptor errorString];
    self.errorLabel.text = errorString;
    [self.delegate reloadTableViewCell:self];
}

- (void)updateValue:(NSString *)newValue
{
    if (![self.inputControlDescriptor.state.value isEqualToString:newValue]) {
        self.inputControlDescriptor.state.value = newValue;
        [self.delegate inputControlCellDidChangedValue:self];
    }
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    _inputControlDescriptor = inputControlDescriptor;
    [self setEnabledCell:(!inputControlDescriptor.readOnly.boolValue)];
    if (inputControlDescriptor.mandatory.boolValue) {
        self.titleLabel.text = [NSString stringWithFormat:@"* %@",inputControlDescriptor.label];
    } else {
        self.titleLabel.text = inputControlDescriptor.label;
    }
    [self updateDisplayingOfErrorMessage];
}

- (void)setEnabledCell:(BOOL)enabled
{
    UIColor *textColor = [[JMThemesManager sharedManager] tableViewCellTitleTextColor];
    self.titleLabel.textColor = [textColor colorWithAlphaComponent:enabled ? 1.0f : 0.5f];
}

@end
