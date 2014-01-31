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
#import "JMBaseRepositoryTableViewController+fetchInputControls.h"
#import "JMConstants.h"
#import "JMRotationBase.h"
#import "JMUtils.h"
#import "UIAlertView+LocalizedAlert.h"
#import "JMLocalization.h"
#import <Objection-iOS/Objection.h>

NSInteger const kJMResourcesLimit = 40;

static NSString * const kJMShowResourceInfoSegue = @"ShowResourceInfo";
static NSString * const kJMUnknownCell = @"UnknownCell";

@interface JMBaseRepositoryTableViewController ()
@property (nonatomic, strong) NSDictionary *cellsIdentifiers;

- (JSResourceLookup *)resourceLookupForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)cellIdentifierForResourceType:(NSString *)resourceType;
@end

@implementation JMBaseRepositoryTableViewController
objection_requires(@"resourceClient", @"constants")
inject_default_rotation()

@synthesize constants = _constants;
@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize resourceDescriptor = _resourceDescriptor;

#pragma mark - Accessors

- (void)setResources:(NSMutableArray *)resources
{
    if (_resources != resources) {
        _resources = resources;
        if (!resources) {
            self.isNeedsToReloadData = YES;
        }
    }
}

- (void)changeServerProfile
{
    if (self.resources) {
        self.resources = nil;
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.tableView reloadData];
    }
}

- (NSDictionary *)cellsIdentifiers
{
    if (!_cellsIdentifiers) {
        _cellsIdentifiers = @{
            self.constants.WS_TYPE_FOLDER : @"FolderCell",
            self.constants.WS_TYPE_REPORT_UNIT : @"ReportCell",
            self.constants.WS_TYPE_DASHBOARD : @"DashboardCell",
        };
    }
    
    return _cellsIdentifiers;
}

- (BOOL)isPaginationAvailable
{
    return self.resourceClient.serverProfile.serverInfo.versionAsInteger >= self.constants.VERSION_CODE_EMERALD_TWO;
}

- (BOOL)isServerVersionSupported
{
    NSInteger serverVersion = self.resourceClient.serverInfo.versionAsInteger;
    BOOL isServerVersionSupported =  serverVersion > self.constants.VERSION_CODE_EMERALD;
    if (!isServerVersionSupported) {
        NSString *title = [NSString stringWithFormat:JMCustomLocalizedString(@"error.server.notsupported.title", nil), serverVersion];
        [[UIAlertView localizedAlertWithTitle:title
                                      message:@"error.server.notsupported.msg"
                                     delegate:nil
                            cancelButtonTitle:@"dialog.button.ok"
                            otherButtonTitles:nil] show];
    }
    return isServerVersionSupported;
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
    self.isNeedsToReloadData = YES;
    
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
    
    if ([self isReportSegue:segue]) {
        [self setResults:sender toDestinationViewController:destinationViewController];
    } else  if ([destinationViewController conformsToProtocol:@protocol(JMResourceClientHolder)]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        JSResourceLookup *resourceLookup = [self resourceLookupForIndexPath:indexPath];
        [destinationViewController setResourceLookup:resourceLookup];
        [destinationViewController setResourceClient:self.resourceClient];
    }
}

- (void)didReceiveMemoryWarning
{
    if (![JMUtils isViewControllerVisible:self]) {
        self.resources = nil;
        self.cellsIdentifiers = nil;
        [self.tableView reloadData];
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
    JSResourceLookup *resourceLookup = [self resourceLookupForIndexPath:indexPath];
    NSString *cellIdentifier = [self cellIdentifierForResourceType:resourceLookup.resourceType];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.textLabel.text = resourceLookup.label;
    cell.detailTextLabel.text = resourceLookup.uri;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSResourceLookup *resourceLookup = [self resourceLookupForIndexPath:indexPath];
    NSArray *supportedResources = self.cellsIdentifiers.allKeys;
    if (![supportedResources containsObject:resourceLookup.resourceType]) {
        [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    } else if ([resourceLookup.resourceType isEqualToString:self.constants.WS_TYPE_REPORT_UNIT]) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self fetchInputControlsForReport:resourceLookup];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:kJMShowResourceInfoSegue sender:cell];
}

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    self.isNeedsToReloadData = NO;
    
    if (!self.resources) {
        self.resources = [NSMutableArray array];
    }
    
    if (!self.isPaginationAvailable) {
        for (JSResourceDescriptor *resourceDescriptor in result.objects) {
            NSString *type = resourceDescriptor.wsType;
            // Show only folder, report and dashboard resources
            if ([type isEqualToString:self.constants.WS_TYPE_FOLDER] ||
                [type isEqualToString:self.constants.WS_TYPE_REPORT_UNIT] ||
                [type isEqualToString:self.constants.WS_TYPE_DASHBOARD]) {
                
                JSResourceLookup *resourceLookup = [[JSResourceLookup alloc] init];
                resourceLookup.label = resourceDescriptor.label;
                resourceLookup.resourceDescription = resourceDescriptor.resourceDescription;
                resourceLookup.resourceType = type;
                resourceLookup.uri = resourceDescriptor.uriString;
                [self.resources addObject:resourceLookup];
            }
        }

        [self.resources sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 resourceType] == self.constants.WS_TYPE_FOLDER) {
                if ([obj2 resourceType] != self.constants.WS_TYPE_FOLDER) {
                    return NSOrderedDescending;
                }
            } else {
                if ([obj2 resourceType] == self.constants.WS_TYPE_FOLDER) {
                    return NSOrderedAscending;
                }
            }
            
            return [[obj1 label] compare:[obj2 label] options:NSCaseInsensitiveSearch];
        }];
    } else {
        [self.resources addObjectsFromArray:result.objects];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Private

- (JSResourceLookup *)resourceLookupForIndexPath:(NSIndexPath *)indexPath
{
    return [self.resources objectAtIndex:indexPath.row];
}

- (NSString *)cellIdentifierForResourceType:(NSString *)resourceType
{
    return [self.cellsIdentifiers objectForKey:resourceType] ?: kJMUnknownCell;
}

@end
