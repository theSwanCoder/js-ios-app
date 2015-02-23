/*
 * TIBCO JasperMobile for iOS
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


#import "JMMenuActionsView.h"
#import "UITableViewCell+Additions.h"
#import "UIImage+Additions.h"

@interface JMMenuActionsView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end


@implementation JMMenuActionsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorColor = [UIColor blackColor];
        self.tableView.backgroundView = nil;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)setAvailableActions:(JMMenuActionsViewAction)availableActions
{
    _availableActions = availableActions;
    [self refreshDatasource];
}

- (void) refreshDatasource
{
    self.dataSource = [NSMutableArray array];
    int i = JMMenuActionsViewActionFirst();
    while (i <= self.availableActions) {
        if (self.availableActions & i) {
            [self.dataSource addObject:@(i)];
        }
        i <<= 1;
    }
    [self.tableView reloadData];
    if (self.tableView.contentSize.height < self.tableView.frame.size.height) {
        [self.tableView sizeToFit];
        CGRect selfRect = self.frame;
        selfRect.size.height = self.tableView.frame.size.height;
        self.frame = selfRect;
    }
    self.tableView.scrollEnabled = (self.tableView.contentSize.height > self.tableView.frame.size.height);
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ActionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [JMFont navigationBarTitleFont];
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageView.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.layer.cornerRadius = 4.0f;
        cell.selectedBackgroundView.backgroundColor = [UIColor darkGrayColor];
    }
    JMMenuActionsViewAction currentAction = [[self.dataSource objectAtIndex:indexPath.row] integerValue];
    cell.textLabel.text = JMCustomLocalizedString([self titleForAction:currentAction], nil);
    cell.imageView.image = [UIImage imageNamed:[self imageNameForAction:currentAction]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.allowsSelection = NO;
    JMMenuActionsViewAction selectedAction = [[self.dataSource objectAtIndex:indexPath.row] integerValue];
    [self.delegate actionsView:self didSelectAction:selectedAction];
}

- (NSString *)titleForAction:(JMMenuActionsViewAction)action
{
    switch (action) {
        case JMMenuActionsViewAction_None:
            return nil;
        case JMMenuActionsViewAction_Filter:
            return @"action.title.edit";
        case JMMenuActionsViewAction_Refresh:
            return @"action.title.refresh";
        case JMMenuActionsViewAction_Save:
            return @"action.title.save";
        case JMMenuActionsViewAction_Delete:
            return @"action.title.delete";
        case JMMenuActionsViewAction_Rename:
            return @"action.title.rename";
        case JMMenuActionsViewAction_MakeFavorite:
            return @"action.title.markasfavorite";
        case JMMenuActionsViewAction_MakeUnFavorite:
            return @"action.title.markasunfavorite";
        case JMMenuActionsViewAction_Info:
            return @"action.title.info";
        case JMMenuActionsViewAction_Sort:
            return @"action.title.sort";
        case JMMenuActionsViewAction_FilterBy:
            return @"action.title.filterBy";
    }
}

- (NSString *)imageNameForAction:(JMMenuActionsViewAction)action
{
    switch (action) {
        case JMMenuActionsViewAction_None:
            return nil;
        case JMMenuActionsViewAction_Filter:
            return @"filter_action";
        case JMMenuActionsViewAction_Refresh:
            return @"refresh_action";
        case JMMenuActionsViewAction_Save:
            return @"save_action";
        case JMMenuActionsViewAction_Delete:
            return @"delete_action";
        case JMMenuActionsViewAction_Rename:
            return @"edit_action";
        case JMMenuActionsViewAction_MakeFavorite:
            return @"make_favorite_item";
        case JMMenuActionsViewAction_MakeUnFavorite:
            return @"favorited_item";
        case JMMenuActionsViewAction_Info:
            return @"info_item";
        case JMMenuActionsViewAction_Sort:
            return @"sort_action";
        case JMMenuActionsViewAction_FilterBy:
            return @"filter_action";

        }
}
@end
