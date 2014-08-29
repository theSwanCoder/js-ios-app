//
//  JMSettingsTableViewCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/10/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMSettingsTableViewCell.h"

@implementation JMSettingsTableViewCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.detailTextLabel.font = [JMFont tableViewCellDetailFont];
    self.textLabel.font = [JMFont tableViewCellTitleFont];
    self.textLabel.textColor = [UIColor darkGrayColor];
    self.contentView.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
}

- (void)setSettingsItem:(JMSettingsItem *)settingsItem{
    _settingsItem = settingsItem;
    self.textLabel.text = settingsItem.titleString;
}

@end
