/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMMultiSelectedItemsVC.h
//  TIBCO JasperMobile
//

#import "JMMultiSelectedItemsVC.h"
#import "JMSelectedItem.h"
#import "NSObject+Additions.h"
#import "JMLocalization.h"

@interface JMMultiSelectedItemsVC() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <JMSelectedItem *>*selectedItems;
@end

@implementation JMMultiSelectedItemsVC

#pragma mark - UIViewController Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *backButtonItem = [self backButtonWithTitle:nil
                                                         target:self
                                                         action:@selector(backButtonTapped)];
    self.navigationItem.leftBarButtonItem = backButtonItem;

    self.selectedItems = [NSMutableArray new];
    for (JMSelectedItem *item in self.availableItems) {
        if (item.selected) {
            [self.selectedItems addObject:item];
        }
    }
}

#pragma mark - Actions
- (void)backButtonTapped
{
    if (self.exitBlock) {
        self.exitBlock(self.selectedItems);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.availableItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JMMultiValuesCell"
                                                            forIndexPath:indexPath];
    JMSelectedItem *item = self.availableItems[indexPath.row];
    cell.textLabel.text = JMLocalizedString(item.titleKey);
    [cell setAccessibility:YES withTextKey:item.titleKey identifier:item.itemAccessibilityId];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMSelectedItem *item = self.availableItems[indexPath.row];
    cell.selected = item.isSelected;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    JMSelectedItem *item = self.availableItems[indexPath.row];
    if ([self.selectedItems containsObject:item]) {
        item.selected = NO;
        cell.selected = NO;
        [self.selectedItems removeObject:item];
    } else {
        item.selected = YES;
        cell.selected = YES;
        [self.selectedItems addObject:item];
    }
}

@end
