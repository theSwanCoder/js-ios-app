/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMTextInputControlCell.h"
#import "UITableViewCell+Additions.h"

@implementation JMTextInputControlCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textField.inputAccessoryView = [self toolbarForInputAccessoryView];
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];
    self.textField.text = inputControlDescriptor.state.value;
}

- (void)setEnabledCell:(BOOL)enabled
{
    [super setEnabledCell:enabled];
    self.textField.enabled = enabled;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateValue:textField.text.length ? textField.text : @""];
    self.inputControlDescriptor.state.error = nil;
    [self updateDisplayingOfErrorMessage];
}

#pragma mark - Actions
- (void)doneButtonTapped:(id)sender
{
    [self updateValue:self.textField.text];
    [self.textField resignFirstResponder];
}
@end
