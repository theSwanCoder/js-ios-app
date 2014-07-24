//
//  JMBooleanServerOptionCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMBooleanServerOptionCell.h"

@interface JMBooleanServerOptionCell ()
@property (weak, nonatomic) IBOutlet UISwitch *switchView;

@end

@implementation JMBooleanServerOptionCell
-(void)setServerOption:(JMServerOption *)serverOption
{
    [super setServerOption:serverOption];
    self.switchView.on = [serverOption.optionValue boolValue];
}

#pragma mark - Actions

- (IBAction)switchChanged:(id)sender
{
    self.serverOption.optionValue = [NSNumber numberWithBool:self.switchView.on];
}
@end
