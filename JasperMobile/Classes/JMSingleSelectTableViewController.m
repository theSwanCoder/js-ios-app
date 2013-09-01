/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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

//
//  JMSingleSelectTableViewController.m
//  Jaspersoft Corporation
//

#import "JMSingleSelectTableViewController.h"
#import "JMLocalization.h"

@implementation JMSingleSelectTableViewController
inject_default_rotation();

- (void)markCell:(UITableViewCell *)cell isSelected:(JMListValue *)listValue
{
    if (listValue.selected) {
        [self.selectedValues addObject:listValue];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        if ([self.selectedValues containsObject:listValue]) {
            [self.selectedValues removeObject:listValue];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.selectedValues = [NSMutableSet set];
    self.unsetButton.title = JMCustomLocalizedString(@"ic.title.unset", nil);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cell.listOfValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ListValueCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    JMListValue *value = [self.cell.listOfValues objectAtIndex:indexPath.row];
    
    cell.textLabel.text = value.name;
    [self markCell:cell isSelected:value];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMListValue *selectedValue = [self.cell.listOfValues objectAtIndex:indexPath.row];
    JMListValue *previousSelectedValue = [self.selectedValues anyObject];

    if (previousSelectedValue != selectedValue) {
        selectedValue.selected = YES;
        previousSelectedValue.selected = NO;
        [self.cell updateWithParameters:[NSSet setWithObject:selectedValue]];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Actions

- (IBAction)unsetAllValues:(id)sender
{
    JMListValue *previousSelectedValue = [self.selectedValues anyObject];

    if (previousSelectedValue != nil) {
        previousSelectedValue.selected = NO;
        [self.cell updateWithParameters:nil];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

@end
