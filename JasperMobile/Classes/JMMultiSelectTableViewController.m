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
//  JMMultiSelectTableViewController.m
//  Jaspersoft Corporation
//

#import "JMMultiSelectTableViewController.h"

@interface JMMultiSelectTableViewController()
@property (nonatomic, strong) NSSet *previousSelectedValues;
@end

@implementation JMMultiSelectTableViewController

@synthesize cell = _cell;

- (void)setCell:(JMSingleSelectInputControlCell *)cell
{
    _cell = cell;

    for (JSInputControlOption *option in cell.listOfValues) {
        if (option.selected.boolValue) {
            [self.selectedValues addObject:option];
        }
    }
}

#pragma mark - UITableViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.previousSelectedValues = [self.selectedValues copy];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![self.previousSelectedValues isEqualToSet:self.selectedValues]) {
        [self.cell updateWithParameters:[self.selectedValues allObjects]];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSInputControlOption *option = [self.cell.listOfValues objectAtIndex:indexPath.row];
    option.selected = [JSConstants stringFromBOOL:!option.selected.boolValue];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (option.selected.boolValue) {
        [self.selectedValues addObject:option];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        if ([self.selectedValues containsObject:option]) {
            [self.selectedValues removeObject:option];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - Actions

- (IBAction)unsetAllValues:(id)sender
{
    for (JSInputControlOption *option in self.selectedValues) {
        option.selected = [JSConstants stringFromBOOL:NO];
    }

    [self.selectedValues removeAllObjects];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
