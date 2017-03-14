/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMMultiSelectTableViewController.h"
#import "JMMenuActionsView.h"
#import "PopoverView.h"
#import "JMLocalization.h"
#import "JMThemesManager.h"
#import "JaspersoftSDK.h"
#import "JMSingleSelectInputControlCell.h"

@interface JMMultiSelectTableViewController () <JMMenuActionsViewDelegate, PopoverViewDelegate>
@property (nonatomic, strong) PopoverView *popoverView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *itemsSegmentedControl;

@end

@implementation JMMultiSelectTableViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = JMLocalizedString(@"report_viewer_options_multiselect_titlelabel_title");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)];

    self.itemsSegmentedControl.tintColor = [[JMThemesManager sharedManager] reportOptionsItemsSegmentedTintColor];
    [self setupSegmentedControlAppearence];
}

- (void) setupSegmentedControlAppearence
{
    NSArray <JSInputControlOption *>*allOptions = self.cell.inputControlDescriptor.state.options;
    NSString *availableTitle = JMLocalizedString(@"report_viewer_options_multiselect_available_title");
    availableTitle = [availableTitle stringByAppendingFormat:@": %zd", allOptions.count];
    [self.itemsSegmentedControl setTitle:availableTitle forSegmentAtIndex:0];
    
    NSString *selectedTitle = JMLocalizedString(@"report_viewer_options_multiselect_selected_title");
    NSArray <JSInputControlOption *> *selectedOptions = [allOptions filteredArrayUsingPredicate:[self selectedValuesPredicate]];
    NSInteger selectedOptionsCount = selectedOptions.count;
    selectedTitle = [selectedTitle stringByAppendingFormat:@": %zd", selectedOptionsCount];
    [self.itemsSegmentedControl setTitle:selectedTitle forSegmentAtIndex:1];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSInputControlOption *option = self.listOfValues[indexPath.row];
    option.selected = !option.selected;
    
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
    JMMenuActionsViewAction availableAction = JMMenuActionsViewAction_ClearSelections;
    if (self.itemsSegmentedControl.selectedSegmentIndex == 0) {
        availableAction |= JMMenuActionsViewAction_SelectAll;
    }
    
    JMMenuActionsView *actionsView = [JMMenuActionsView new];
    actionsView.delegate = self;
    [actionsView setAvailableActions:availableAction
                     disabledActions:JMMenuActionsViewAction_None];
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
        option.selected = (action == JMMenuActionsViewAction_SelectAll);
    }
    [self applyFiltering];
    [self setupSegmentedControlAppearence];

    [self.popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.2f];
}

@end
