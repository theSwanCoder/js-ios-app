/*
 * Tibco JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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


#import "JMMultiSelectTableViewController.h"

@implementation JMMultiSelectTableViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = JMCustomLocalizedString(@"detail.report.options.multiselect.titlelabel.title", nil);
}

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithNibName:NSStringFromClass([JMSingleSelectTableViewController class]) bundle:nil];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSInputControlOption *option = [self.listOfValues objectAtIndex:indexPath.row];
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

@end
