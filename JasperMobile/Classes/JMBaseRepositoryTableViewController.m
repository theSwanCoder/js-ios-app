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
//  JMRepositoryTableViewController.m
//  Jaspersoft Corporation
//

#import "JMBaseRepositoryTableViewController.h"
#import "JMConstants.h"
#import "JMUtils.h"
#import <Objection-iOS/Objection.h>

static NSString * const kJMShowResourceInfoSegue = @"ShowResourceInfo";
static NSString * const kJMUnknownCell = @"UnknownCell";

@interface JMBaseRepositoryTableViewController ()
@property (nonatomic, strong, readonly) NSDictionary *cellsIdentifiers;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;

- (JSResourceDescriptor *)resourceDescriptorForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)cellIdentifierForResourceType:(NSString *)resourceType;
@end

@implementation JMBaseRepositoryTableViewController
objection_requires(@"resourceClient", @"constants")
inject_default_rotation()

- (BOOL)isNeedsToReloadData
{
    return self.resources == nil;
}

- (void)changeServerProfile
{
    if (self.resources) {
        self.resources = nil;
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.tableView reloadData];
    }
}

#pragma mark - Accessors

@synthesize constants = _constants;
@synthesize cellsIdentifiers = _cellsIdentifiers;
@synthesize resourceClient = _resourceClient;
@synthesize resourceDescriptor = _resourceDescriptor;

- (NSDictionary *)cellsIdentifiers
{
    if (!_cellsIdentifiers) {
        _cellsIdentifiers = @{
            self.constants.WS_TYPE_FOLDER : @"FolderCell",
            self.constants.WS_TYPE_IMG : @"ImageCell",
            self.constants.WS_TYPE_REPORT_UNIT : @"ReportCell",
            self.constants.WS_TYPE_DASHBOARD : @"DashboardCell",
            self.constants.WS_TYPE_CSS : @"TextCell",
            self.constants.WS_TYPE_XML : @"TextCell"
        };
    }
    
    return _cellsIdentifiers;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:kJMShowResourceInfoSegue sender:cell];
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
    
        // Add observer to refresh controller after profile was changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeServerProfile)
                                                 name:kJMChangeServerProfileNotification
                                               object:nil];
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [JMUtils setTitleForResourceViewController:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    
    if ([destinationViewController conformsToProtocol:@protocol(JMResourceClientHolder)]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        self.lastIndexPath = indexPath;
        JSResourceDescriptor *resourceDescriptor = [self resourceDescriptorForIndexPath:indexPath];
        [destinationViewController setResourceDescriptor:resourceDescriptor];
        [destinationViewController setResourceClient:self.resourceClient];
    }
    
    if ([segue.identifier isEqualToString:kJMShowResourceInfoSegue]) {
        [destinationViewController setDelegate:self];
    }
}

- (void)didReceiveMemoryWarning
{
    if (![JMUtils isViewControllerVisible:self]) {
        self.resources = nil;
        self.lastIndexPath = nil;
        self.resourceDescriptor = nil;
        [self.tableView reloadData];
        _cellsIdentifiers = nil;
    }
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resources count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSResourceDescriptor *resourceDescriptor = [self resourceDescriptorForIndexPath:indexPath];
    NSString *cellIdentifier = [self cellIdentifierForResourceType:resourceDescriptor.wsType];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.textLabel.text = resourceDescriptor.label;
    cell.detailTextLabel.text = resourceDescriptor.uriString;
        
    return cell;
}

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    self.resources = [result.objects mutableCopy];
    
    // TODO: move comparator to sdk
    [self.resources sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 wsType] == self.constants.WS_TYPE_FOLDER) {
            if ([obj2 wsType] != self.constants.WS_TYPE_FOLDER) {
                return NSOrderedDescending;
            }
        } else {
            if ([obj2 wsType] == self.constants.WS_TYPE_FOLDER) {
                return NSOrderedAscending;
            }
        }
        
        return [[obj1 label] compare:[obj2 label] options:NSCaseInsensitiveSearch];
    }];
    
    [self.tableView reloadData];
}

#pragma mark - JMResourceTableViewControllerDelegate

- (void)removeResource
{    
    [self.resources removeObjectAtIndex:self.lastIndexPath.row];
    [self.tableView reloadData];
}

- (void)refreshWithResource:(JSResourceDescriptor *)resourceDescriptor
{
    [self.resources replaceObjectAtIndex:self.lastIndexPath.row withObject:resourceDescriptor];
    [self.tableView reloadRowsAtIndexPaths:@[self.lastIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Private

- (JSResourceDescriptor *)resourceDescriptorForIndexPath:(NSIndexPath *)indexPath
{
    return [self.resources objectAtIndex:indexPath.row];
}

- (NSString *)cellIdentifierForResourceType:(NSString *)resourceType
{
    return [self.cellsIdentifiers objectForKey:resourceType] ?: kJMUnknownCell;
}

@end
