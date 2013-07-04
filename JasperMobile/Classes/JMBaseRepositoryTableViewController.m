//
//  JMRepositoryTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/27/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMBaseRepositoryTableViewController.h"
#import "JMUtils.h"
#import "JMCancelRequestPopup.h"
#import "UIAlertView+LocalizedAlert.h"
#import <Objection-iOS/Objection.h>

#define kJMShowResourceInfoSegue @"ShowResourceInfo"
#define kJMUnknownCell @"UnknownCell"

@interface JMBaseRepositoryTableViewController ()
@property (nonatomic, strong) NSMutableArray *resources;
@property (nonatomic, strong, readonly) NSDictionary *cellIdentifiers;

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
@synthesize cellIdentifiers = _cellIdentifiers;

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
    [JMUtils awakeFromNibForResourceViewController:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Presents cancel request popup
    [JMCancelRequestPopup presentInViewController:self progressMessage:@"status.loading" restClient:self.resourceClient cancelBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    id destinationViewController = segue.destinationViewController;
    
    if ([destinationViewController conformsToProtocol:@protocol(JMResourceClientHolder)]) {
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
    JSResourceDescriptor *resoruceDescriptor = [self resourceDescriptorForIndexPath:indexPath];
    NSString *cellIdentifier = [self cellIdentifierForResourceType:resoruceDescriptor.wsType];
    
    if ([cellIdentifier isEqualToString:kJMUnknownCell]) {
        [self performSegueWithIdentifier:kJMShowResourceInfoSegue sender:self];
    }
}

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    self.resources = [result.objects mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - JMResourceViewControllerDelegate

- (void)removeResource:(JSResourceDescriptor *)resourceDescriptor
{
    for (JSResourceDescriptor *resource in self.resources) {
        if ([resource.uriString isEqualToString:resourceDescriptor.uriString]) {
            [self.resources removeObject:resource];
            [self.tableView reloadData];
            break;
        }
    }
}

#pragma mark - Private

- (JSResourceDescriptor *)resourceDescriptorForIndexPath:(NSIndexPath *)indexPath
{
    return [self.resources objectAtIndex:[indexPath indexAtPosition:1]];
}

- (NSString *)cellIdentifierForResourceType:(NSString *)resourceType
{
    return [self.cellIdentifiers objectForKey:resourceType] ?: kJMUnknownCell;
}

@end
