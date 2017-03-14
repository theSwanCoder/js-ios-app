/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


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
    self.serverOption.optionValue = @(self.checkBoxButton.selected);
}

@end
