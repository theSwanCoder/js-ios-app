/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2014 Jaspersoft Corporation. All rights reserved.
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

@implementation JMSingleSelectTableViewController

- (void)setCell:(JMSingleSelectInputControlCell *)cell
{
    _cell = cell;

    for (JSInputControlOption *option in cell.listOfValues) {
        if (option.selected.boolValue) {
            [self.selectedValues addObject:option];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[cell.listOfValues indexOfObject:option] inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle  animated:YES];
            break;
        }
    }
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.selectedValues = [NSMutableSet set];
    self.unsetButton.title = JMCustomLocalizedString(@"ic.title.unset", nil);
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.cell.disableUnsetFunctional) {
        self.unsetButton.title = nil;
    }
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
    
    JSInputControlOption *option = [self.cell.listOfValues objectAtIndex:indexPath.row];
    cell.textLabel.text = option.label;
    cell.accessoryType = option.selected.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSInputControlOption *selectedOption = [self.cell.listOfValues objectAtIndex:indexPath.row];
    JSInputControlOption *previousSelectedOption = [self.selectedValues anyObject];

    if (previousSelectedOption != selectedOption) {
        selectedOption.selected = [JSConstants stringFromBOOL:YES];
        previousSelectedOption.selected = [JSConstants stringFromBOOL:NO];
        [self.cell updateWithParameters:@[selectedOption]];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Actions

- (IBAction)unsetAllValues:(id)sender
{
    JSInputControlOption *previousSelectedOption = [self.selectedValues anyObject];

    if (previousSelectedOption != nil) {
        previousSelectedOption.selected = [JSConstants stringFromBOOL:NO];
        [self.cell updateWithParameters:nil];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

@end
