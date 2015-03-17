/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
//  JMMenuViewController.h
//  TIBCO JasperMobile
//

#import "JMMenuViewController.h"
#import "JMMenuItem.h"
#import "SWRevealViewController.h"
#import "JMMenuItemTableViewCell.h"
#import "JMMainNavigationController.h"
#import "JMLibraryCollectionViewController.h"
#import "JMSavedItemsCollectionViewController.h"
#import "JMFavoritesCollectionViewController.h"
#import "JMSettingsViewController.h"
#import "JMServerProfile.h"
#import "JMServerProfile+Helpers.h"
#import "JMConstants.h"
#import <Crashlytics/Crashlytics.h>

@interface JMMenuViewController() <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *organizationNameLabel;
@property (strong, nonatomic) NSArray *menuItems;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;
@end

@implementation JMMenuViewController

#pragma mark - LifeCycle
-(void)dealloc
{
    NSLog(@"%@ -%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateServerInfo) name:kJMLoginDidSuccessNotification object:nil];
    
    [self updateServerInfo];
    
    // version and build
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.appVersionLabel.text = [NSString stringWithFormat:@"v. %@ (%@)", version, build];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - Utils
- (void)updateServerInfo
{
    NSString *alias = self.restClient.serverProfile.alias;
    NSString *version = self.restClient.serverProfile.serverInfo.version;
    self.serverNameLabel.text = [NSString stringWithFormat:@"%@ (v.%@)", alias, version];
    self.userNameLabel.text = self.restClient.serverProfile.username;
    self.organizationNameLabel.text = self.restClient.serverProfile.organization;
}

- (void)unselectItems
{
    for(JMMenuItem *item in self.menuItems) {
        if (item.selected) {
            item.selected = NO;
        }
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMMenuItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JMMenuItemTableViewCell"
                                                                    forIndexPath:indexPath];
    JMMenuItem *menuItem = self.menuItems[indexPath.row];
    cell.itemName = menuItem.title;
    cell.itemIcon = [self iconWithResourceType:menuItem.resourceType];
    cell.selectedItemIcon = [self selectedIconWithResourceType:menuItem.resourceType];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self setSelectedItemIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
    JMMenuItem *menuItem = self.menuItems[indexPath.row];
    cell.selected = menuItem.selected;
}

#pragma mark - Public API
- (void) setSelectedItemIndex:(NSUInteger)itemIndex
{
    [self unselectItems];
    if (itemIndex < self.menuItems.count) {
        JMMenuItem *item = [self.menuItems objectAtIndex:itemIndex];
        item.selected = YES;
        
        
        if (item.resourceType != JMResourceTypeLogout) {
            if([item vcIdentifierForSelectedItem]) {
                UINavigationController *nvc = [self.storyboard instantiateViewControllerWithIdentifier:[item vcIdentifierForSelectedItem]];
                self.revealViewController.frontViewController = nvc;
                [self.revealViewController setFrontViewPosition:FrontViewPositionLeft
                                                       animated:YES];
            }
        } else {
            [[JMSessionManager sharedManager] logout];
            [JMUtils showLoginViewAnimated:YES completion:@weakself(^(void)) {
                [self setSelectedItemIndex:0];
            } @weakselfend];
        }
    }
}

#pragma mark - Properties
- (NSArray *)menuItems
{
    if (!_menuItems) {
        _menuItems = @[
                       [JMMenuItem menuItemWithTitle:JMCustomLocalizedString(@"menuitem.library.label", nil)
                                        resourceType:JMResourceTypeLibrary],
                       [JMMenuItem menuItemWithTitle:JMCustomLocalizedString(@"menuitem.repository.label", nil)
                                        resourceType:JMResourceTypeRepository],
                       [JMMenuItem menuItemWithTitle:JMCustomLocalizedString(@"menuitem.saveditems.label", nil)
                                        resourceType:JMResourceTypeSavedItems],
                       [JMMenuItem menuItemWithTitle:JMCustomLocalizedString(@"menuitem.favorites.label", nil)
                                        resourceType:JMResourceTypeFavorites],
                       [JMMenuItem menuItemWithTitle:JMCustomLocalizedString(@"menuitem.settings.label", nil)
                                        resourceType:JMResourceTypeSettings],
                       [JMMenuItem menuItemWithTitle:JMCustomLocalizedString(@"menuitem.logout.label", nil)
                                        resourceType:JMResourceTypeLogout]
                       ];
    }
    return _menuItems;
}

#pragma mark - Private API
- (UIImage *)iconWithResourceType:(JMResourceType)resourceType
{
    switch (resourceType) {
        case JMResourceTypeLibrary:
            return [UIImage imageNamed:@"ic_library"];
        case JMResourceTypeRepository:
            return [UIImage imageNamed:@"ic_repository"];
        case JMResourceTypeSavedItems:
            return [UIImage imageNamed:@"ic_saved_items"];
        case JMResourceTypeFavorites:
            return [UIImage imageNamed:@"ic_favorites"];
        case JMResourceTypeSettings:
            return [UIImage imageNamed:@"ic_settings"];
        default:
            return nil;
    }
}

- (UIImage *)selectedIconWithResourceType:(JMResourceType)resourceType
{
    switch (resourceType) {
        case JMResourceTypeLibrary:
            return [UIImage imageNamed:@"ic_library_selected"];
        case JMResourceTypeRepository:
            return [UIImage imageNamed:@"ic_repository_selected"];
        case JMResourceTypeSavedItems:
            return [UIImage imageNamed:@"ic_saved_items_selected"];
        case JMResourceTypeFavorites:
            return [UIImage imageNamed:@"ic_favorites_selected"];
        case JMResourceTypeSettings:
            return [UIImage imageNamed:@"ic_settings_selected"];
        default:
            return nil;
    }
}

@end
