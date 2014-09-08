/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2014 Jaspersoft Corporation. All rights reserved.
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
#import "JMCancelRequestPopup.h"
#import "JMFavoritesUtil.h"
#import "JMUtils.h"
#import "UITableViewCell+SetSeparators.h"
#import "JMRequestDelegate.h"
#import <Objection-iOS/Objection.h>

// Declared as define const because of int to NSNumber conversion trick (i.e.
// we can use literal @kJMAttributesSection to represent NSNumber)
#define kJMAttributesSection 0
#define kJMToolsSection 1

static NSString * const kJMTitleKey = @"title";
static NSString * const kJMValueKey = @"value";

@interface JMResourceTableViewController ()
@property (nonatomic, strong) NSDictionary *numberOfRowsForSections;
@property (nonatomic, strong) NSDictionary *resourceDescriptorProperties;
@property (nonatomic, strong) NSDictionary *cellIdentifiers;
@property (nonatomic, strong) JMFavoritesUtil *favoritesUtil;
@property (nonatomic, weak) UIButton *favoriteButton;

- (void)refreshResourceDescriptor;
- (NSDictionary *)resourceDescriptorPropertyForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)localizedTextLabelTitleForProperty:(NSString *)property;
@end

@implementation JMResourceTableViewController
objection_requires(@"resourceClient", @"favoritesUtil")

#pragma mark - Accessors

@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize resourceDescriptor = _resourceDescriptor;
@synthesize resourceDescriptorProperties = _resourceDescriptorProperties;
@synthesize numberOfRowsForSections = _numberOfRowsForSections;
@synthesize cellIdentifiers = _cellIdentifiers;

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
            @kJMToolsSection : @1
        };
    }
    
    return _numberOfRowsForSections;
}

- (NSDictionary *)cellIdentifiers
{
    if (!_cellIdentifiers) {
        _cellIdentifiers = @{
            @kJMAttributesSection : @"ResourceAttributeCell",
            @kJMToolsSection : @"ResourceToolsCell"
        };
    }
    
    return _cellIdentifiers;
}

- (void)setResourceDescriptor:(JSResourceDescriptor *)resourceDescriptor
{
    if (_resourceDescriptor != resourceDescriptor) {
        _resourceDescriptor = resourceDescriptor;
        // Also update properties for resource descriptor
        _resourceDescriptorProperties = nil;
    }
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
    [JMUtils setTitleForResourceViewController:self];
    [self refreshResourceDescriptor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.resourceDescriptor) {
        // Persist old changes, if they were made previously. This is required
        // because for some reason "viewWillAppear" method of 2-nd view controller is
        // called earlier then "viewWillDisappear" of 1-st one (storyboard bug?).
        // This is true even if view controllers are same type
        [self.favoritesUtil persist];
        [self.favoritesUtil setResource:self.resourceDescriptor.uriString
                                  label:self.resourceDescriptor.label
                                   type:self.resourceDescriptor.wsType];
        // Update favorite button if needed
        if (self.favoriteButton) {
            [self changeFavoriteButton:self.favoriteButton isResourceInFavorites:[self.favoritesUtil isResourceInFavorites]];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.favoritesUtil persist];
}

- (void)didReceiveMemoryWarning
{
    if (![JMUtils isViewControllerVisible:self]) {
        self.numberOfRowsForSections = nil;
        self.resourceDescriptorProperties = nil;
        self.cellIdentifiers = nil;
    }
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.numberOfRowsForSections.count;
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
        
        CGFloat separatorHeight = 1.0f;
        UIColor *separatorColor = self.tableView.separatorColor;

        [cell setTopSeparatorWithHeight:separatorHeight color:separatorColor tableViewStyle:self.tableView.style];
        
        NSInteger numberOfRows = [[self.numberOfRowsForSections objectForKey:@kJMAttributesSection] integerValue];
        // Check if we have last row
        if (indexPath.row == numberOfRows - 1) {
            [cell setBottomSeparatorWithHeight:separatorHeight color:separatorColor tableViewStyle:self.tableView.style];
        }
    } else if (section == kJMToolsSection) {
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.backgroundColor = [UIColor clearColor];
        self.favoriteButton = (UIButton *) [cell viewWithTag:1];
        BOOL isResourceInFavorites = self.resourceDescriptor != nil && [self.favoritesUtil isResourceInFavorites];
        [self changeFavoriteButton:self.favoriteButton isResourceInFavorites:isResourceInFavorites];
    }
    
    return cell;
}

// Calculate height for table view cell according to amount of text inside cell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger section = indexPath.section;
//    NSString *cellIdentifier = [self cellIdentifierForSection:indexPath.section];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    
//    if (section == kJMToolsSection) {
//        return cell.frame.size.height;
//    }
//    
//    NSString *text,
//             *detailText;    
//    UITableViewCellStyle cellStyle = UITableViewCellStyleValue2;
//    NSDictionary *propertyForIndexPath = [self resourceDescriptorPropertyForIndexPath:indexPath];
//    text = [self localizedTextLabelTitleForProperty:[propertyForIndexPath objectForKey:kJMTitleKey]];
//    detailText = [propertyForIndexPath objectForKey:kJMValueKey];
//
//    return [self relativeHeightForTableViewCell:cell text:text detailText:detailText cellStyle:cellStyle];
    return tableView.rowHeight;
}

#pragma mark - Actions

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

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    self.resourceDescriptor = [result.objects objectAtIndex:0];
    [self.favoritesUtil setResource:self.resourceDescriptor.uriString
                              label:self.resourceDescriptor.label
                               type:self.resourceDescriptor.wsType];
    [self.tableView reloadData];
}

#pragma mark - Private

- (void)refreshResourceDescriptor
{
    __weak JMResourceTableViewController *weakSelf = self;

    [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];

    [self.resourceClient resource:self.resourceLookup.uri delegate:[JMRequestDelegate checkRequestResultForDelegate:self viewControllerToDismiss:self]];
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

- (void)changeFavoriteButton:(UIButton *)button isResourceInFavorites:(BOOL)isResourceInFavorites
{
    if (!isResourceInFavorites) {
        [button setTitle:JMCustomLocalizedString(@"dialog.button.addfavorite", nil) forState:UIControlStateNormal];
        [JMUtils setBackgroundImagesForButton:button
                                    imageName:@"add_favorite_button.png"
                         highlightedImageName:@"add_favorite_button_highlighted.png"
                                   edgesInset:18.0f];
    } else {
        [button setTitle:JMCustomLocalizedString(@"dialog.button.removefavorite", nil) forState:UIControlStateNormal];
        [JMUtils setBackgroundImagesForButton:button
                                    imageName:@"remove_favorite_button.png"
                         highlightedImageName:@"remove_favorite_button_highlighted.png"
                                   edgesInset:18.0f];
    }
}

@end
