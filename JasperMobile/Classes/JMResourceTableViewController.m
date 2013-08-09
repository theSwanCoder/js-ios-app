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
//  JMResourceTableViewController.m
//  Jaspersoft Corporation
//

#import "JMResourceTableViewController.h"
#import "JMBaseRepositoryTableViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMFavoritesUtil.h"
#import "JMFilter.h"
#import "JMLocalization.h"
#import "JMRotationBase.h"
#import "JMUtils.h"
#import "UIAlertView+LocalizedAlert.h"
#import "UITableViewController+CellRelativeHeight.h"
#import <Objection-iOS/Objection.h>

// Declared as define const because of int to NSNumber convertion trick (i.e.
// we can use literal @kJMAttributesSection to represent NSNumber)
#define kJMAttributesSection 0
#define kJMToolsSection 1
#define kJMResourcePropertiesSection 2

static NSInteger const kJMConfirmButtonIndex = 1;

static NSString * const kJMTitleKey = @"title";
static NSString * const kJMValueKey = @"value";

static NSString * const kJMEditResourceDescriptorSegue = @"EditResourceDescriptor";

typedef enum {
    JMGetResourceRequest,
    JMDeleteResourceRequest
} JMRequestType;

@interface JMResourceTableViewController ()
@property (nonatomic, strong, readonly) NSDictionary *numberOfRowsForSections;
@property (nonatomic, strong, readonly) NSDictionary *resourceDescriptorProperties;
@property (nonatomic, strong, readonly) NSDictionary *cellIdentifiers;
@property (nonatomic, strong) JMFavoritesUtil *favoritesUtil;
@property (nonatomic, assign) JMRequestType requestType;
@property (nonatomic, weak) UIButton *favoriteButton;

- (void)refreshResourceDescriptor;
- (void)reloadToolsSection;
- (JSResourceProperty *)resourcePropertyForIndexPath:(NSIndexPath *)indexPath;
- (NSDictionary *)resourceDescriptorPropertyForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)localizedTextLabelTitleForProperty:(NSString *)property;
@end

@implementation JMResourceTableViewController
objection_requires(@"resourceClient", @"favoritesUtil");
inject_default_rotation();

#pragma mark - Accessors

@synthesize resourceClient = _resourceClient;
@synthesize resourceDescriptor = _resourceDescriptor;
@synthesize resourceDescriptorProperties = _resourceDescriptorProperties;
@synthesize numberOfRowsForSections = _numberOfRowsForSections;
@synthesize cellIdentifiers = _cellIdentifiers;
@synthesize needsToRefreshResourceDescriptorData = _needsToRefreshResourceDescriptorData;

- (NSDictionary *)resourceDescriptorProperties
{
    if (!_resourceDescriptorProperties) {
        _resourceDescriptorProperties = @{
            @0 : @{
              kJMTitleKey : @"name",
              kJMValueKey : self.resourceDescriptor.name ?: @""
            },
            @1 : @{
              kJMTitleKey : @"label",
              kJMValueKey : self.resourceDescriptor.label ?: @""
            },
            @2 : @{
              kJMTitleKey : @"description",
              kJMValueKey : self.resourceDescriptor.resourceDescription ?: @""
            },
            @3 : @{
              kJMTitleKey : @"type",
              kJMValueKey : self.resourceDescriptor.wsType ?: @""
            }
        };
    }
    
    return _resourceDescriptorProperties;
}

- (NSDictionary *)numberOfRowsForSections
{
    if (!_numberOfRowsForSections) {
        _numberOfRowsForSections = @{
            @kJMAttributesSection : @4,
            @kJMToolsSection : @1,
            @kJMResourcePropertiesSection : [NSNumber numberWithInt:self.resourceDescriptor.resourceProperties.count]
        };
    }
    
    return _numberOfRowsForSections;
}

- (NSDictionary *)cellIdentifiers
{
    if (!_cellIdentifiers) {
        _cellIdentifiers = @{
            @kJMAttributesSection : @"ResourceAttributeCell",
            @kJMToolsSection : @"ResourceToolsCell",
            @kJMResourcePropertiesSection : @"ResourcePropertyCell"
        };
    }
    
    return _cellIdentifiers;
}

- (void)setResourceDescriptor:(JSResourceDescriptor *)resourceDescriptor
{
    if (_resourceDescriptor != resourceDescriptor) {
        _resourceDescriptor = resourceDescriptor;
        // Update the number of rows for resource properties section by re-creating
        // numberOfRowsForSections variable
        _numberOfRowsForSections = nil;
        // Also update properties for resource descriptor
        _resourceDescriptorProperties = nil;
    }
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [JMUtils setTitleForResourceViewController:self];
    [self refreshResourceDescriptor];
    self.resourceDescriptor = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id  destinationViewController = segue.destinationViewController;
    
    if ([destinationViewController conformsToProtocol:@protocol(JMResourceClientHolder)]) {
        [destinationViewController setResourceDescriptor:self.resourceDescriptor];
    }
    
    if ([segue.identifier isEqualToString:kJMEditResourceDescriptorSegue]) {
        [destinationViewController setDelegate:self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.needsToRefreshResourceDescriptorData) {
        [self refreshResourceDescriptor];
    }

    // TODO: remove if main menu will be changed to "List" instead tab bar controller
    if (self.resourceDescriptor) {
        // Persist old changes, if they were made previously. This is required
        // because for some reason "viewWillAppear" method of 2-nd view controller is
        // called earlier then "viewWillDisappear" of 1-st one (storyboard bug?).
        // This is true even if view controllers are same type
        [self.favoritesUtil persist];
        self.favoritesUtil.resourceDescriptor = self.resourceDescriptor;
        
        // Update favorite button if needed
        if (self.favoriteButton) {
            [self changeFavoriteButton:self.favoriteButton isResourceInFavorites:[self.favoritesUtil isResourceInFavorites]];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.favoritesUtil persist];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.numberOfRowsForSections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == kJMResourcePropertiesSection ? JMCustomLocalizedString(@"resource.properties.title", nil) : @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.numberOfRowsForSections objectForKey:[NSNumber numberWithInt:section]] integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSString *cellIdentifier = [self cellIdentifierForSection:section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];;
    
    if (section == kJMAttributesSection) {
        NSDictionary *propertyForIndexPath = [self resourceDescriptorPropertyForIndexPath:indexPath];
        NSString *title = [propertyForIndexPath objectForKey:kJMTitleKey];
        NSString *value = [propertyForIndexPath objectForKey:kJMValueKey];
        
        cell.textLabel.text = [self localizedTextLabelTitleForProperty:title];
        cell.detailTextLabel.text = value;
    } else if (section == kJMToolsSection) {
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        
        self.favoriteButton = (UIButton *)[cell viewWithTag:1];
        UIButton *deleteButton = (UIButton *)[cell viewWithTag:2];
        
        [deleteButton setTitle:JMCustomLocalizedString(@"dialog.button.delete", nil) forState:UIControlStateNormal];
        
        BOOL isResourceInFavorites = self.resourceDescriptor ? [self.favoritesUtil isResourceInFavorites] : NO;
        [self changeFavoriteButton:self.favoriteButton isResourceInFavorites:isResourceInFavorites];
    } else if (section == kJMResourcePropertiesSection) {
        JSResourceProperty *resourceProperty = [self resourcePropertyForIndexPath:indexPath];
        
        cell.textLabel.text = resourceProperty.name;
        cell.detailTextLabel.text = resourceProperty.value;
    }
    
    return cell;
}

// Calculate height for table view cell according to amount of text inside cell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSString *cellIdentifier = [self cellIdentifierForSection:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (section == kJMToolsSection) {
        return cell.frame.size.height;
    }
    
    NSString *text,
             *detailText;    
    UITableViewCellStyle cellStyle = UITableViewCellStyleValue2;
    
    if (section == kJMAttributesSection) {
        NSDictionary *propertyForIndexPath = [self resourceDescriptorPropertyForIndexPath:indexPath];
        text = [self localizedTextLabelTitleForProperty:[propertyForIndexPath objectForKey:kJMTitleKey]];
        detailText = [propertyForIndexPath objectForKey:kJMValueKey];
    } else if (section == kJMResourcePropertiesSection) {
        JSResourceProperty *property = [self resourcePropertyForIndexPath:indexPath];
        text = property.name;
        detailText = property.value;
        cellStyle = UITableViewCellStyleSubtitle;
    }
        
    return [self relativeHeightForTableViewCell:cell text:text detailText:detailText cellStyle:cellStyle];
}

#pragma mark - Actions

- (IBAction)deleteResource:(id)sender
{
    [[UIAlertView localizedAlertWithTitle:@"delete.dialog.title"
                         message:@"delete.dialog.msg"
                        delegate:self
               cancelButtonTitle:@"dialog.button.cancel"
               otherButtonTitles:@"dialog.button.yes", nil] show];
}

- (IBAction)favoriteButtonClicked:(id)sender
{
    BOOL isResourceInFavorites = [self.favoritesUtil isResourceInFavorites];
    
    if (!isResourceInFavorites) {
        [self.favoritesUtil addToFavorites];
        [self changeFavoriteButton:sender isResourceInFavorites:YES];
    } else {
        [self.favoritesUtil removeFromFavorites];
        [self changeFavoriteButton:sender isResourceInFavorites:NO];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == kJMConfirmButtonIndex) {
        [JMFilter checkNetworkReachabilityForBlock:^{
            self.requestType = JMDeleteResourceRequest;
            [self.resourceClient deleteResource:self.resourceDescriptor.uriString delegate:[JMFilter checkRequestResultForDelegate:self]];
        } viewControllerToDismiss:nil];
    }
}

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    if (self.requestType == JMGetResourceRequest) {
        self.resourceDescriptor = [result.objects objectAtIndex:0];
        self.favoritesUtil.resourceDescriptor = self.resourceDescriptor;
        
        if (self.needsToRefreshResourceDescriptorData) {
            self.needsToRefreshResourceDescriptorData = NO;
            [self.delegate refreshWithResource:self.resourceDescriptor];
        }
        
        [self.tableView reloadData];
    } else if (self.requestType == JMDeleteResourceRequest) {
        if ([self.favoritesUtil isResourceInFavorites]) {
            [self.favoritesUtil removeFromFavorites];
        }
        
        [self.delegate removeResource];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Private

- (void)refreshResourceDescriptor
{
    [JMFilter checkNetworkReachabilityForBlock:^{
        [JMCancelRequestPopup presentInViewController:self progressMessage:@"status.loading" restClient:self.resourceClient cancelBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        self.requestType = JMGetResourceRequest;
        [self.resourceClient resource:self.resourceDescriptor.uriString delegate:[JMFilter checkRequestResultForDelegate:self]];
    } viewControllerToDismiss:self];
}

- (JSResourceProperty *)resourcePropertyForIndexPath:(NSIndexPath *)indexPath
{
    return [self.resourceDescriptor.resourceProperties objectAtIndex:indexPath.row];
}

- (NSDictionary *)resourceDescriptorPropertyForIndexPath:(NSIndexPath *)indexPath
{
    return [self.resourceDescriptorProperties objectForKey:[NSNumber numberWithInt:indexPath.row]];
}

- (NSString *)cellIdentifierForSection:(NSInteger)section
{
    return [self.cellIdentifiers objectForKey:[NSNumber numberWithInt:section]];
}

- (NSString *)localizedTextLabelTitleForProperty:(NSString *)property
{
    return JMCustomLocalizedString([NSString stringWithFormat:@"resource.%@.title", property], nil);
}

- (void)reloadToolsSection
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:kJMToolsSection];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}

- (void)changeFavoriteButton:(UIButton *)button isResourceInFavorites:(BOOL)isResourceInFavorites
{
    if (!isResourceInFavorites) {
        [button setTitle:JMCustomLocalizedString(@"dialog.button.addfavorite", nil) forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"add_favorite_button.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"add_favorite_button_highlighted.png"] forState:UIControlStateHighlighted];
    } else {
        [button setTitle:JMCustomLocalizedString(@"dialog.button.removefavorite", nil) forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"remove_favorite_button.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"remove_favorite_button_highlighted.png"] forState:UIControlStateHighlighted];
    }
}

@end
