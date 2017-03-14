/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMSaveResourceNameCell.h"

@implementation JMSaveResourceNameCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.errorLabel.font = [[JMThemesManager sharedManager] tableViewCellErrorFont];
    self.errorLabel.textColor = [[JMThemesManager sharedManager] tableViewCellErrorColor];
    self.textField.placeholder = JMLocalizedString(@"resource_viewer_save_name");
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.cellDelegate respondsToSelector:@selector(nameCell:didChangeResourceName:)]) {
        [self.cellDelegate nameCell:self didChangeResourceName:textField.text];
    }
}

@end
