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


#import "JMMultiSelectTableViewController.h"
#import "JMMenuActionsView.h"
#import "PopoverView.h"

@interface JMMultiSelectTableViewController () <JMMenuActionsViewDelegate, PopoverViewDelegate>
@property (nonatomic, strong) PopoverView *popoverView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *itemsSegmentedControl;

@end

@implementation JMMultiSelectTableViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = JMCustomLocalizedString(@"report.viewer.options.multiselect.titlelabel.title", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)];

    self.itemsSegmentedControl.tintColor = [[JMThemesManager sharedManager] reportOptionsItemsSegmentedTintColor];
    [self setupSegmentedControlAppearence];
}

- (void) setupSegmentedControlAppearence
{
    NSString *availableTitle = JMCustomLocalizedString(@"report.viewer.options.multiselect.available.title", nil);
    availableTitle = [availableTitle stringByAppendingFormat:@": %zd", self.cell.inputControlDescriptor.state.options.count];
    [self.itemsSegmentedControl setTitle:availableTitle forSegmentAtIndex:0];
    
    NSString *selectedTitle = JMCustomLocalizedString(@"report.viewer.options.multiselect.selected.title", nil);
    selectedTitle = [selectedTitle stringByAppendingFormat:@": %zd", self.selectedValues.count];
    [self.itemsSegmentedControl setTitle:selectedTitle forSegmentAtIndex:1];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSInputControlOption *option = self.listOfValues[indexPath.row];
    option.selected = [JSUtils stringFromBOOL:!option.selected.boolValue];
    
    if (self.itemsSegmentedControl.selectedSegmentIndex != 0) {
        [self applyFiltering];
    } else {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self setupSegmentedControlAppearence];
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

- (IBAction)itemsSegmentedControlDidChangedValue:(id)sender
{
    [self applyFiltering];
    [self.tableView reloadData];
}

- (NSPredicate *)filteredPredicateWithText:(NSString *)text
{
    NSMutableArray *predicates = [NSMutableArray array];
    NSPredicate *filterPredicate = [super filteredPredicateWithText:text];
    if (filterPredicate) {
        [predicates addObject:filterPredicate];
    }
    if (self.itemsSegmentedControl.selectedSegmentIndex != 0) {
        [predicates addObject:[super selectedValuesPredicate]];
    }
    
    if (predicates.count) {
        if (predicates.count > 1) {
            return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        } else {
            return [predicates firstObject];
        }
    }
    return nil;
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
    for (JSInputControlOption *option in self.listOfValues) {
        option.selected = [JSUtils stringFromBOOL:(action == JMMenuActionsViewAction_SelectAll)];
    }
    [self.tableView reloadData];
    
    [self.popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.2f];
}

@end
