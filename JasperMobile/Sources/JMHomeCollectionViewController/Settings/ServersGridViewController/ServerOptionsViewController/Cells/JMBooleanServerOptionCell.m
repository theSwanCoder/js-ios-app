//
//  JMBooleanServerOptionCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMBooleanServerOptionCell.h"

@implementation JMBooleanServerOptionCell
-(void)setServerOption:(JMServerOption *)serverOption
{
    [super setServerOption:serverOption];
    self.checkBoxButton.userInteractionEnabled = serverOption.editable;
    self.checkBoxButton.selected = [serverOption.optionValue boolValue];
}

#pragma mark - Actions
- (IBAction)checkButtonTapped:(id)sender
{
    self.checkBoxButton.selected = !self.checkBoxButton.selected;
    self.serverOption.optionValue = [NSNumber numberWithBool:self.checkBoxButton.selected];
}

@end
