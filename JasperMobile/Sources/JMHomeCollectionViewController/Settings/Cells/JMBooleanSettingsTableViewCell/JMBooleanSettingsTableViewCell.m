//
//  JMBooleanSettingsTableViewCell.m
//  Tibco JasperMobile
//
//  Created by Oleksii Gubariev on 10/20/14.
//  Copyright (c) 2014 Tibco JasperMobile. All rights reserved.
//

#import "JMBooleanSettingsTableViewCell.h"

@interface JMBooleanSettingsTableViewCell()
@property (nonatomic, weak) IBOutlet UISwitch *valueSwitcher;
@end

@implementation JMBooleanSettingsTableViewCell

-(void)setSettingsItem:(JMSettingsItem *)settingsItem
{
    [super setSettingsItem:settingsItem];
    self.valueSwitcher.on = [settingsItem.valueSettings boolValue];
}

#pragma mark - Actions
- (IBAction)switcherValueDidChanged:(id)sender
{
    self.settingsItem.valueSettings = [NSNumber numberWithBool:self.valueSwitcher.on];
}
@end
