/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMTextServerOptionCell.h"
#import "UITableViewCell+Additions.h"
#import "JMTextField.h"
#import "UIColor+RGBComponent.h"
#import "JMThemesManager.h"


@interface JMTextServerOptionCell () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet JMTextField *textField;

@end

@implementation JMTextServerOptionCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textField.inputAccessoryView = [self toolbarForInputAccessoryView];
}

-(void)setServerOption:(JMServerOption *)serverOption
{
    [super setServerOption:serverOption];
    self.textField.enabled = serverOption.editable;
    self.textField.text = serverOption.optionValue;

    UIColor *placeholderColor = [UIColor сolorFromColor:self.textField.textColor differents:0.25 increase:YES];
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [[JMThemesManager sharedManager] menuItemDescriptionFont],
                                 NSForegroundColorAttributeName : placeholderColor
                                 };
    NSString *trimmedPlaceholderString = [serverOption.titleString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" *"]];
    
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:trimmedPlaceholderString
                                                                      attributes:attributes];
    self.textField.attributedPlaceholder = placeholder;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.serverOption.optionValue = textField.text ? : nil;
    [self updateDisplayingOfErrorMessage];
}

#pragma mark - Actions

- (void)doneButtonTapped:(id)sender
{
    [self.textField resignFirstResponder];
}

@end
