//
//  JMResourceViewerActionsView.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/16/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMResourceViewerActionsView.h"
#import "UITableViewCell+Additions.h"


@interface JMResourceViewerActionsView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end


@implementation JMResourceViewerActionsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)setAvailableActions:(JMResourceViewerAction)availableActions
{
    _availableActions = availableActions;
    [self refreshDatasource];
}

- (void) refreshDatasource
{
    self.dataSource = [NSMutableArray array];
    int i = JMResourceViewerActionFirst();
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
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageView.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    JMResourceViewerAction currentAction = [[self.dataSource objectAtIndex:indexPath.row] integerValue];
    cell.textLabel.text = JMCustomLocalizedString([self titleForAction:currentAction], nil);
    cell.imageView.image = [UIImage imageNamed:[self imageNameForAction:currentAction]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.allowsSelection = NO;
    JMResourceViewerAction selectedAction = [[self.dataSource objectAtIndex:indexPath.row] integerValue];
    [self.delegate actionsView:self didSelectAction:selectedAction];
}

- (NSString *)titleForAction:(JMResourceViewerAction)action
{
    switch (action) {
        case JMResourceViewerAction_Filter:
            return @"action.title.edit";
        case JMResourceViewerAction_Refresh:
            return @"action.title.refresh";
        case JMResourceViewerAction_Save:
            return @"action.title.save";
        case JMResourceViewerAction_Delete:
            return @"action.title.delete";
        case JMResourceViewerAction_Rename:
            return @"action.title.rename";
        default:
            return nil;
    }
}

- (NSString *)imageNameForAction:(JMResourceViewerAction)action
{
    switch (action) {
        case JMResourceViewerAction_Filter:
            return @"filter_action";
        case JMResourceViewerAction_Refresh:
            return @"refresh_action";
        case JMResourceViewerAction_Save:
            return @"save_action";
        case JMResourceViewerAction_Delete:
            return @"delete_action";
        case JMResourceViewerAction_Rename:
            return @"edit_action";
        default:
            return nil;
    }
}
@end
