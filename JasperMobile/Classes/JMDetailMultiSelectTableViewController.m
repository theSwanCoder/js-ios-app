//
//  JMDetailMultiSelectTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/16/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMDetailMultiSelectTableViewController.h"

@interface JMDetailMultiSelectTableViewController ()
@property (nonatomic, strong) NSSet *previousSelectedValues;
@end

@implementation JMDetailMultiSelectTableViewController

@synthesize cell = _cell;

#pragma mark - Accessors

- (void)setCell:(JMSingleSelectInputControlCell *)cell
{
    _cell = cell;
    
    for (JSInputControlOption *option in cell.listOfValues) {
        if (option.selected.boolValue) {
            [self.selectedValues addObject:option];
        }
    }
}

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithNibName:NSStringFromClass([JMDetailSingleSelectTableViewController class]) bundle:nil];
}

#pragma mark - UITableViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.previousSelectedValues = [self.selectedValues copy];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (![self.previousSelectedValues isEqualToSet:self.selectedValues]) {
        [self.cell updateWithParameters:[self.selectedValues allObjects]];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSInputControlOption *option = [self.cell.listOfValues objectAtIndex:indexPath.row];
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
