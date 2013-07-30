//
//  JMRepositoryTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/27/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMBaseRepositoryTableViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMRotationBase.h"
#import "JMUtils.h"
#import "UIAlertView+LocalizedAlert.h"
#import <Objection-iOS/Objection.h>

static NSString * const kJMShowResourceInfoSegue = @"ShowResourceInfo";
static NSString * const kJMUnknownCell = @"UnknownCell";

@interface JMBaseRepositoryTableViewController ()
@property (nonatomic, strong) NSMutableArray *resources;
@property (nonatomic, strong, readonly) NSDictionary *cellsIdentifiers;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;

- (JSResourceDescriptor *)resourceDescriptorForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)cellIdentifierForResourceType:(NSString *)resourceType;
@end

@implementation JMBaseRepositoryTableViewController
objection_requires(@"resourceClient", @"constants");
inject_default_rotation()

#pragma mark - Accessors

@synthesize resourceClient = _resourceClient;
@synthesize constants = _constants;
@synthesize resourceDescriptor = _resourceDescriptor;
@synthesize cellsIdentifiers = _cellIdentifiers;

- (NSDictionary *)cellIdentifiers
{
    if (!_cellIdentifiers) {
        _cellIdentifiers = @{
            self.constants.WS_TYPE_FOLDER : @"FolderCell",
            self.constants.WS_TYPE_IMG : @"ImageCell",
            self.constants.WS_TYPE_REPORT_UNIT : @"ReportCell",
            self.constants.WS_TYPE_DASHBOARD : @"DashboardCell",
            self.constants.WS_TYPE_CSS : @"TextCell",
            self.constants.WS_TYPE_XML : @"TextCell"
        };
    }
    
    return _cellIdentifiers;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:kJMShowResourceInfoSegue sender:cell];
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
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
    }
    
    if ([segue.identifier isEqualToString:kJMShowResourceInfoSegue]) {
        [destinationViewController setDelegate:self];
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSResourceDescriptor *resourceDescriptor = [self resourceDescriptorForIndexPath:indexPath];
    NSString *cellIdentifier = [self cellIdentifierForResourceType:resourceDescriptor.wsType];
    
    if ([cellIdentifier isEqualToString:kJMUnknownCell]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:kJMShowResourceInfoSegue sender:cell];
    }
}

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    self.resources = [result.objects mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - JMResourceViewControllerDelegate

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
