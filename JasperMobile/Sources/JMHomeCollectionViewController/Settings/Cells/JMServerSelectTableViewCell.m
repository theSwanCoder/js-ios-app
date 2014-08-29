//
//  JMServerSelectTableViewCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/7/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMServerSelectTableViewCell.h"

@implementation JMServerSelectTableViewCell

-(void)setSettingsItem:(JMSettingsItem *)settingsItem
{
    [super setSettingsItem:settingsItem];
    self.detailTextLabel.text = settingsItem.valueSettings;
}
@end
