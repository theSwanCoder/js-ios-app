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


#import "JMMultiSelectTableViewController.h"
#import "JMMenuActionsView.h"
#import "PopoverView.h"

@interface JMMultiSelectTableViewController () <JMMenuActionsViewDelegate, PopoverViewDelegate>
@property (nonatomic, strong) PopoverView *popoverView;

@end

@implementation JMMultiSelectTableViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = JMCustomLocalizedString(@"report.viewer.options.multiselect.titlelabel.title", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)];

}

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithNibName:NSStringFromClass([JMSingleSelectTableViewController class]) bundle:nil];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSInputControlOption *option = self.listOfValues[indexPath.row];
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

- (void)actionButtonClicked:(id) sender
{
    JMMenuActionsView *actionsView = [JMMenuActionsView new];
    actionsView.delegate = self;
    actionsView.availableActions = JMMenuActionsViewAction_SelectAll | JMMenuActionsViewAction_ClearSelections;
    CGPoint point = CGPointMake(CGRectGetWidth(self.view.frame), -10);
    
    self.popoverView = [PopoverView showPopoverAtPoint:point
                                                inView:self.view
                                             withTitle:nil
                                       withContentView:actionsView
                                              delegate:self];
}

#pragma mark - PopoverViewDelegate Methods
- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    self.popoverView = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGPoint point = CGPointMake(self.view.frame.size.width, -10);
    [self.popoverView animateRotationToNewPoint:point inView:self.view withDuration:duration];
}


#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [self.selectedValues removeAllObjects];
    if (action == JMMenuActionsViewAction_SelectAll) {
        [self.selectedValues addObjectsFromArray:self.listOfValues];
    }
    
    for (JSInputControlOption *option in self.listOfValues) {
        option.selected = [JSConstants stringFromBOOL:(action == JMMenuActionsViewAction_SelectAll)];
    }
    [self.tableView reloadData];
    
    [self.popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.2f];
}

@end
