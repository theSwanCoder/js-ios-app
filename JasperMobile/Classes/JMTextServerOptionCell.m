//
//  JMTextServerOptionCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMTextServerOptionCell.h"

@interface JMTextServerOptionCell ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation JMTextServerOptionCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14.0f, 0)];
    self.textField.leftView = paddingView;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.background = [self.textField.background resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10.0f, 0, 10.0f)];
}

-(void)setServerOption:(JMServerOption *)serverOption
{
    [super setServerOption:serverOption];
    self.textField.text = serverOption.optionValue;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.serverOption.optionValue = textField.text;
}

@end
