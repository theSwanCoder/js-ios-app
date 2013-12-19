/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JMSearchFilterTableViewController.m
//  Jaspersoft Corporation
//

#import "JMUtils.h"
#import "JMRotationBase.h"
#import "JMLocalization.h"
#import "JMSearchFilterTableViewController.h"
#import "UITableViewCell+SetSeparators.h"
#import <Objection-iOS/Objection.h>

static NSInteger const kJMResourceTypesSection = 0;
static NSInteger const kJMApplyFilterSection = 1;

static NSString * const kJMCellIdentifier = @"identifier";
static NSString * const kJMCellResourceTypes = @"types";
static NSString * const kJMCellText = @"text";

@interface JMSearchFilterTableViewController ()
@property (nonatomic, strong) NSDictionary *cellsProperties;
@end

@implementation JMSearchFilterTableViewController
objection_requires(@"constants")
inject_default_rotation()

@synthesize resourceTypes = _resourceTypes;

- (void)didReceiveMemoryWarning
{
    self.cellsProperties = nil;
    [super didReceiveMemoryWarning];
}

#pragma mark - Accessors

- (NSDictionary *)cellsProperties
{
    if (!_cellsProperties) {
        _cellsProperties = @{
            @0 : @{
                kJMCellIdentifier : @"AllResourcesCell",
                kJMCellResourceTypes : [NSSet setWithObjects:self.constants.WS_TYPE_REPORT_UNIT, self.constants.WS_TYPE_DASHBOARD, nil],
                kJMCellText : JMCustomLocalizedString(@"filter.resources.type.all", nil)
            },
            @1 : @{
                kJMCellIdentifier : @"ReportsCell",
                kJMCellResourceTypes : [NSSet setWithObjects:self.constants.WS_TYPE_REPORT_UNIT, nil],
                kJMCellText : JMCustomLocalizedString(@"filter.resources.type.reportUnit", nil)
            },
            @2 : @{
                kJMCellIdentifier : @"DashboardCell",
                kJMCellResourceTypes : [NSSet setWithObjects:self.constants.WS_TYPE_DASHBOARD, nil],
                kJMCellText : JMCustomLocalizedString(@"filter.resources.type.dashboard", nil)
            },
        };
    }

    return _cellsProperties;
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kJMResourceTypesSection) {
        return self.cellsProperties.count;
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    switch (indexPath.section) {
        case kJMResourceTypesSection: {
            NSDictionary *cellProperties = [self.cellsProperties objectForKey:@(indexPath.row)];
            cell = [tableView dequeueReusableCellWithIdentifier:[cellProperties objectForKey:kJMCellIdentifier]];
            cell.textLabel.text = [cellProperties objectForKey:kJMCellText];
            
            if ([[cellProperties objectForKey:kJMCellResourceTypes] isEqualToSet:self.resourceTypes]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            // Check if separator was not added to this cell already
            if (cell.tag == 1) break;
            
            CGFloat separatorHeight = 0.7f;
            [cell setTopSeparatorWithHeight:separatorHeight color:self.tableView.separatorColor tableViewStyle:self.tableView.style];
            // Check if this is the last cell
            if (indexPath.row == self.cellsProperties.count - 1) {
                [cell setBottomSeparatorWithHeight:separatorHeight color:self.tableView.separatorColor tableViewStyle:self.tableView.style];
            }
            
            cell.tag = 1;

            break;
        }

        case kJMApplyFilterSection:
        default: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"ApplyCell"];
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
            cell.backgroundColor = [UIColor clearColor];

            UIButton *run = (UIButton *) [cell viewWithTag:1];
            [run setTitle:JMCustomLocalizedString(@"dialog.button.applyUpdate", nil) forState:UIControlStateNormal];
            [JMUtils setBackgroundImagesForButton:run
                                        imageName:@"run_report_button.png"
                             highlightedImageName:@"run_report_button_highlighted.png"
                                       edgesInset:18.0f];
            break;
        }
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSSet *selectedResourceTypes = [[self.cellsProperties objectForKey:@(indexPath.row)] objectForKey:kJMCellResourceTypes];
    self.resourceTypes = [selectedResourceTypes mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - Actions

- (IBAction)applyFilter:(id)sender
{
    [self.delegate setResourceTypes:self.resourceTypes];
    [self.delegate refresh];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
