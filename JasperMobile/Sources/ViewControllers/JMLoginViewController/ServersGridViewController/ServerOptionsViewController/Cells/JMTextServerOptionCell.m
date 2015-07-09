/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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


#import "JMTextServerOptionCell.h"
#import "UITableViewCell+Additions.h"

@interface JMTextServerOptionCell () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation JMTextServerOptionCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textField.background = [self.textField.background resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10.0f, 0, 10.0f)];
    self.textField.inputAccessoryView = [self toolbarForInputAccessoryView];
}

-(void)setServerOption:(JMServerOption *)serverOption
{
    [super setServerOption:serverOption];
    self.textField.enabled = serverOption.editable;
    self.textField.text = serverOption.optionValue;

    NSDictionary *attributes = @{
            NSFontAttributeName : [UIFont systemFontOfSize:12]
    };
    NSString *trimmedPlaceholderString = [serverOption.titleString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" *"]];
    
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:trimmedPlaceholderString
                                                                      attributes:attributes];
    self.textField.attributedPlaceholder = placeholder;

    self.textField.textColor = serverOption.editable ? [UIColor darkTextColor] : [UIColor lightGrayColor];
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
