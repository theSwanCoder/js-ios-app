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
#import "JMLocalization.h"
#import "JMFont.h"
#import "JMMenuAction.h"

CGFloat static kJMMenuActionsViewCellHeight = 40;

@interface JMMenuActionsView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end


@implementation JMMenuActionsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.tableView = [self tableViewWithFrame:self.bounds];
        [self addSubview:_tableView];
        [self setupDatasource];
    }
    return self;
}

- (UITableView *)tableViewWithFrame:(CGRect)frame
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorColor = [UIColor blackColor];
    tableView.backgroundView = nil;
    tableView.delegate = self;
    tableView.dataSource = self;
    return tableView;
}

- (void)setAvailableActions:(JMMenuActionsViewAction)availableActions
{
    _availableActions = availableActions;
    [self refreshDatasource];
    
    [self updateFrameFitContent];

    [self.tableView reloadData];
}

- (void)setupDatasource
{
    self.dataSource = @[
            [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_MakeFavorite
                                     available:NO
                                       enabled:YES],
            [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_MakeUnFavorite
                                     available:NO
                                       enabled:YES],
            [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Refresh
                                     available:NO
                                       enabled:YES],
            [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Filter
                                     available:NO
                                       enabled:YES],
            [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Edit
                                     available:NO
                                       enabled:YES],
            [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Sort
                                     available:NO
                                       enabled:YES],
            [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Save
                                     available:NO
                                       enabled:YES],
            [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Delete
                                     available:NO
                                       enabled:YES],
            [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Rename
                                     available:NO
                                       enabled:YES],
            [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_SelectAll
                                     available:NO
                                       enabled:YES],
            [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_ClearSelections
                                     available:NO
                                       enabled:YES],
            [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Run
                                     available:NO
                                       enabled:YES],
            [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Print
                                     available:NO
                                       enabled:YES],
            [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Info
                                     available:NO
                                       enabled:YES],
    ];
}

- (void)refreshDatasource
{
    //self.dataSource = [NSMutableArray array];
    int i = JMMenuActionsViewActionFirst();
    while (i <= self.availableActions) {
        if (self.availableActions & i) {
            //[self.dataSource addObject:@(i)];
        }
        i <<= 1;
    }
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
    return kJMMenuActionsViewCellHeight;
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

#pragma mark - Public API
// need this call this method after adding or removing items
- (void)updateFrameFitContent
{
    NSInteger countOfActions = self.dataSource.count;
    CGFloat tableViewHeight = kJMMenuActionsViewCellHeight * countOfActions;
    CGRect selfRect = self.frame;
    selfRect.size.height = tableViewHeight;
    CGFloat leftPadding = 20;
    CGFloat rightPadding = 20;
    CGFloat iconToTextDistance = 20;
    selfRect.size.width = leftPadding + [self maxImageWidth] + iconToTextDistance + [self maxTextWidth] + rightPadding;
    self.frame = CGRectIntegral(selfRect);
    self.tableView.frame = CGRectIntegral(selfRect);
    
    [self.tableView sizeToFit];
    self.tableView.scrollEnabled = NO;
}

- (CGFloat)maxTextWidth
{
    CGFloat maxTextWidth = .0f;
    for (NSNumber *actionNumber in self.dataSource) {
        JMMenuActionsViewAction action = actionNumber.integerValue;
        NSString *titleAction = JMCustomLocalizedString([self titleForAction:action], nil);
        NSDictionary *titleTextAttributes = @{NSFontAttributeName : [JMFont navigationBarTitleFont]};
        CGSize titleActionContainerSize = [titleAction sizeWithAttributes:titleTextAttributes];
        if (maxTextWidth < titleActionContainerSize.width) {
            maxTextWidth = titleActionContainerSize.width;
        }
    }
    return maxTextWidth;
}

- (CGFloat)maxImageWidth
{
    CGFloat maxImageWidth = .0f;
    for (NSNumber *actionNumber in self.dataSource) {
        JMMenuActionsViewAction action = actionNumber.integerValue;
        UIImage *iconAction = [UIImage imageNamed:[self imageNameForAction:action]];
        if (maxImageWidth < iconAction.size.width) {
            maxImageWidth = iconAction.size.width;
        }
    }
    return maxImageWidth;
}

@end
