//
//  JMMultiSelectTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/16/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

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
