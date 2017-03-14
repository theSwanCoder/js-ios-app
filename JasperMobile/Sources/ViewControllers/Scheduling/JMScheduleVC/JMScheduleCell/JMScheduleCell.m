/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMScheduleCell.h"
#import "JMUtils.h"

@interface JMScheduleCell ()
@property(nonatomic, weak) IBOutlet UILabel *errorLabel;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *titleLabelCenterYConstraint;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *textFieldCenterYConstraint;
@end

@implementation JMScheduleCell

#pragma mark - Public API
- (void)showErrorMessage:(NSString *)message
{
    self.errorLabel.text = message;
    self.titleLabelCenterYConstraint.constant = (message.length == 0) ? 0 : -10;
    self.textFieldCenterYConstraint.constant = (message.length == 0) ? 0 : -10;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(scheduleCellDidStartChangeValue:)]) {
        [self.delegate scheduleCellDidStartChangeValue:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(scheduleCellDidEndChangeValue:)]) {
        [self.delegate scheduleCellDidEndChangeValue:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *currentString = textField.text;

    NSString *changedString;

    if (range.length == 1) {
        // remove symbol
        changedString = [currentString stringByReplacingCharactersInRange:range withString:@""];
    } else if (range.location == 0 && range.length > 1) {
        // autocompleted text
        changedString = string;
    } else {
        // add symbol
        NSRange firstPartOfStringRange = NSMakeRange(0, range.location);
        NSString *firstPartOfString = [currentString substringWithRange:firstPartOfStringRange];

        NSRange lastPartOfStringRange = NSMakeRange(range.location, currentString.length - range.location);
        NSString *lastPartOfString = [currentString substringWithRange:lastPartOfStringRange];

        changedString = [NSString stringWithFormat:@"%@%@%@", firstPartOfString, string, lastPartOfString];
    }

    if ([self.delegate respondsToSelector:@selector(scheduleCell:didChangeValue:)]) {
        [self.delegate scheduleCell:self didChangeValue:changedString];
    }

    JMLog(@"changed string: %@", changedString);

    return YES;
}

@end
