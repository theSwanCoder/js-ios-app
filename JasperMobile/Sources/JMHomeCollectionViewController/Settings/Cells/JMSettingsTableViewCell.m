//
//  JMSettingsTableViewCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/10/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMSettingsTableViewCell.h"

@implementation JMSettingsTableViewCell
- (void)setSettingsItem:(JMSettingsItem *)settingsItem{
    _settingsItem = settingsItem;
    self.titleLabel.text = settingsItem.titleString;
}

@end
