/*
 * Tibco JasperMobile for iOS
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


#import "JMSettingsViewController.h"
#import "UITableViewCell+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import "JMSettingsTableViewCell.h"
#import "JMSettings.h"
#import "UIAlertView+LocalizedAlert.h"
#import "JMServerProfile+Helpers.h"
#import <SplunkMint-iOS/SplunkMint-iOS.h>

#import "JMAppUpdater.h"

@interface JMSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *settingsTitleLabel;

@property (nonatomic, strong) JMSettings *detailSettings;
@end

@implementation JMSettingsViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.settingsTitleLabel.textColor = kJMDetailViewLightTextColor;
    self.tableView.layer.cornerRadius = 4;

    self.settingsTitleLabel.text = [JMCustomLocalizedString(@"detail.settings.title", nil) capitalizedString];
    
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info_item"] style:UIBarButtonItemStyleBordered target:self action:@selector(applicationInfo:)];
    UIBarButtonItem *applyItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"apply_item"] style:UIBarButtonItemStyleBordered  target:self action:@selector(saveButtonTapped:)];
    self.navigationItem.rightBarButtonItems = @[applyItem, infoItem];
    [[Mint sharedInstance] logEventAsyncWithTag:@"With last enabled" completionBlock:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshDataSource];
}

- (void) refreshDataSource
{
    self.detailSettings = [[JMSettings alloc] init];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.detailSettings.itemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMSettingsItem *currentItem = [self.detailSettings.itemsArray objectAtIndex:indexPath.row];
    JMSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:currentItem.cellIdentifier];
    [cell setBottomSeparatorWithHeight:1 color:tableView.separatorColor tableViewStyle:tableView.style];
    cell.settingsItem = currentItem;
    return cell;
}

#pragma mark - Actions
- (IBAction)saveButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    [self.detailSettings saveSettings];
    [self.navigationController popViewControllerAnimated:YES];
    [[Mint sharedInstance] logEventAsyncWithTag:@"With last disabled" completionBlock:nil];
}

- (void)applicationInfo:(id)sender
{
    NSString *appName = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *message = [NSString stringWithFormat:JMCustomLocalizedString(@"servers.info", nil), appName, [JMAppUpdater latestAppVersionAsString], [JMServerProfile minSupportedServerVersion]];
    [[UIAlertView localizedAlertWithTitle:nil
                                  message:message
                                 delegate:nil
                        cancelButtonTitle:@"dialog.button.ok"
                        otherButtonTitles:nil] show];
}
@end
