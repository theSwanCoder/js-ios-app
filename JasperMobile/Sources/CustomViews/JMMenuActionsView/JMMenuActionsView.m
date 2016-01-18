/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
#import "UIImage+Additions.h"
#import "JMLocalization.h"
#import "JMMenuAction.h"

#import "UIColor+RGBComponent.h"


CGFloat static kJMMenuActionsViewCellHeight = 40;

@interface JMMenuActionsView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *dataSource;
@property (nonatomic, strong) NSArray *availableMenuActions;

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
        self.tableView.separatorColor = [UIColor darkGrayColor];
    }
    return self;
}

- (UITableView *)tableViewWithFrame:(CGRect)frame
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    return tableView;
}

- (void)setAvailableActions:(JMMenuActionsViewAction)availableActions
{
    _availableActions = availableActions;
    [self refreshDatasourceForAvailableActions];
    [self updateFrameFitContent];
    [self.tableView reloadData];
}

- (void)setAvailableActions:(JMMenuActionsViewAction)availableActions disabledActions:(JMMenuActionsViewAction)disabledActions
{
    _availableActions = availableActions;
    _disabledActions = disabledActions;
    [self resetDataSource];
    [self refreshDatasourceForAvailableActions];
    [self refreshDatasourceForDisabledActions];
    [self updateFrameFitContent];
    [self.tableView reloadData];
}

- (void)setupDatasource
{
    self.dataSource = @{
            @(JMMenuActionsViewAction_MakeFavorite) : [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_MakeFavorite
                                                                               available:NO
                                                                                 enabled:YES],
            @(JMMenuActionsViewAction_MakeUnFavorite) : [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_MakeUnFavorite
                                                                                 available:NO
                                                                                   enabled:YES],
            @(JMMenuActionsViewAction_Refresh) : [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Refresh
                                                                          available:NO
                                                                            enabled:YES],
            @(JMMenuActionsViewAction_Filter) : [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Filter
                                                                         available:NO
                                                                           enabled:YES],
            @(JMMenuActionsViewAction_Edit) : [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Edit
                                                                       available:NO
                                                                         enabled:YES],
            @(JMMenuActionsViewAction_Sort) : [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Sort
                                                                       available:NO
                                                                         enabled:YES],
            @(JMMenuActionsViewAction_Save) : [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Save
                                                                       available:NO
                                                                         enabled:YES],
            @(JMMenuActionsViewAction_Delete) : [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Delete
                                                                         available:NO
                                                                           enabled:YES],
            @(JMMenuActionsViewAction_Rename) : [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Rename
                                                                         available:NO
                                                                           enabled:YES],
            @(JMMenuActionsViewAction_SelectAll) : [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_SelectAll
                                                                            available:NO
                                                                              enabled:YES],
            @(JMMenuActionsViewAction_ClearSelections) : [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_ClearSelections
                                                                                  available:NO
                                                                                    enabled:YES],
            @(JMMenuActionsViewAction_Run) : [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Run
                                                                      available:NO
                                                                        enabled:YES],
            @(JMMenuActionsViewAction_Print) : [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Print
                                                                        available:NO
                                                                          enabled:YES],
            @(JMMenuActionsViewAction_Info) : [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_Info
                                                                       available:NO
                                                                         enabled:YES],
            @(JMMenuActionsViewAction_OpenIn) : [JMMenuAction menuActionWithAction:JMMenuActionsViewAction_OpenIn
                                                                       available:NO
                                                                         enabled:YES],
    };
}

- (void)refreshDatasourceForAvailableActions
{
    NSMutableArray *availableMenuActions = [NSMutableArray array];
    NSInteger i = JMMenuActionsViewActionFirst();
    while (i <= self.availableActions) {
        if (self.availableActions & i) {
            JMMenuAction *menuAction = self.dataSource[@(i)];
            menuAction.actionAvailable = YES;
            [availableMenuActions addObject:menuAction];
        }
        i <<= 1;
    }
    self.availableMenuActions = [availableMenuActions copy];
}

- (void)refreshDatasourceForDisabledActions
{
    NSInteger i = JMMenuActionsViewActionFirst();
    while (i <= self.disabledActions) {
        if (self.disabledActions & i) {
            JMMenuAction *menuAction = self.dataSource[@(i)];
            menuAction.actionEnabled = NO;
        }
        i <<= 1;
    }
}


#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger availableActionCount = self.availableMenuActions.count;
    return availableActionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ActionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [[JMThemesManager sharedManager] navigationBarTitleFont];
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageView.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.layer.cornerRadius = 4.0f;
        cell.selectedBackgroundView.backgroundColor = [UIColor darkGrayColor];
    }
    JMMenuAction *currentMenuAction = self.availableMenuActions[indexPath.row];
    cell.textLabel.text = JMCustomLocalizedString(currentMenuAction.actionTitle, nil);
    
    cell.imageView.image = [UIImage imageNamed:currentMenuAction.actionImageName];
    cell.imageView.alpha = currentMenuAction.actionEnabled ? 1.0f : 0.5f;
    UIColor *textColor = [[JMThemesManager sharedManager] popupsTextColor];
    cell.textLabel.textColor = [textColor colorWithAlphaComponent:currentMenuAction.actionEnabled ? 1.0f : 0.5f];
    cell.userInteractionEnabled = currentMenuAction.actionEnabled;
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
    JMMenuAction *selectedMenuAction = self.availableMenuActions[indexPath.row];
    [self.delegate actionsView:self didSelectAction:selectedMenuAction.menuAction];
}

#pragma mark - Public API
// need this call this method after adding or removing items
- (void)updateFrameFitContent
{
    NSInteger countOfActions = self.availableMenuActions.count;
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
    for (JMMenuAction *menuAction in self.availableMenuActions) {
        NSString *titleAction = JMCustomLocalizedString(menuAction.actionTitle, nil);
        NSDictionary *titleTextAttributes = @{NSFontAttributeName : [[JMThemesManager sharedManager] navigationBarTitleFont]};
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
    for (JMMenuAction *menuAction in self.availableMenuActions) {
        UIImage *iconAction = [UIImage imageNamed:menuAction.actionImageName];
        if (maxImageWidth < iconAction.size.width) {
            maxImageWidth = iconAction.size.width;
        }
    }
    return maxImageWidth;
}

#pragma mark - Helpers
- (void)resetDataSource
{
    for (JMMenuAction *menuAction in self.dataSource.allValues) {
        menuAction.actionEnabled = YES;
        menuAction.actionAvailable = NO;
    }
}

@end
