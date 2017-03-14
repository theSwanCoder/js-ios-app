/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMBooleanInputControlCell.h"

@interface JMBooleanInputControlCell ()
@property (nonatomic, weak) IBOutlet UISwitch *uiSwitch;
@end

@implementation JMBooleanInputControlCell

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];
    self.uiSwitch.on = [inputControlDescriptor.state.value boolValue];
}

- (void)setEnabledCell:(BOOL)enabled
{
    [super setEnabledCell:enabled];
    self.uiSwitch.enabled = enabled;
}

#pragma mark - Actions

- (IBAction)switchChanged:(id)sender
{
    [self performSelector:@selector(updateValue:) withObject:[JSUtils stringFromBOOL:[sender isOn]] afterDelay:0.1]; // Fix issue with animations
}

@end
