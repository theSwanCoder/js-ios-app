//
//  JMTextSettingsTableViewCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMTextSettingsTableViewCell.h"

@interface JMTextSettingsTableViewCell ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation JMTextSettingsTableViewCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textField.background = [self.textField.background resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10.0f, 0, 10.0f)];
}

-(void)setSettingsItem:(JMSettingsItem *)settingsItem
{
    [super setSettingsItem:settingsItem];
    self.textField.text = settingsItem.valueSettings;
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
    self.settingsItem.valueSettings = textField.text;
}

@end
