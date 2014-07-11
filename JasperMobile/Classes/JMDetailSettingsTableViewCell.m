//
//  JMDetailSettingsTableViewCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/10/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMDetailSettingsTableViewCell.h"

@interface JMDetailSettingsTableViewCell () <UITextFieldDelegate>
@property (nonatomic, readwrite) UITextField *valueTextField;
@end

@implementation JMDetailSettingsTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = [UIColor darkGrayColor];
        self.textLabel.font = [UIFont systemFontOfSize:18];
        
        self.valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, self.contentView.bounds.size.height)];
        self.valueTextField.textColor = [UIColor darkGrayColor];
        self.valueTextField.textAlignment = NSTextAlignmentCenter;
        self.valueTextField.borderStyle = UITextBorderStyleNone;
        self.valueTextField.returnKeyType = UIReturnKeyDone;
        self.valueTextField.keyboardType = UIKeyboardTypeNumberPad;
        self.valueTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.valueTextField.delegate = self;
        
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryView = self.valueTextField;
    }
    return self;
}

- (void)setSettingsItem:(JMDetailSettingsItem *)settingsItem{
    _settingsItem = settingsItem;
    self.textLabel.text = settingsItem.titleString;
    self.valueTextField.text = settingsItem.valueString;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    NSMutableString *newString = [NSMutableString stringWithString:textField.text];
    [newString replaceCharactersInRange:range withString:string];
    NSInteger currentValue = [newString integerValue];

    return (([string isEqualToString:filtered]) && (NSLocationInRange(currentValue, self.settingsItem.availableRange)));
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.settingsItem.valueString = textField.text;
}

@end
