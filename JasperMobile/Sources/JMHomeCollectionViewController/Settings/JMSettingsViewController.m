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


#import "JMSettingsViewController.h"
#import "UITableViewCell+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import "JMSettingsTableViewCell.h"
#import "JMSettings.h"
#import "UIAlertView+LocalizedAlert.h"
#import "JMServerProfile+Helpers.h"

#import "JMAppUpdater.h"
#import "JMIntroViewController.h"
#import "UIView+Additions.h"
#import "JMOnboardIntroViewController.h"

@interface JMSettingsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    JMSettingsItem *currentItem = [self.detailSettings.itemsArray objectAtIndex:indexPath.row];
    if ([currentItem.cellIdentifier isEqualToString:kJMBaseCellIdentifier]) {
        [self showIntroView];
    }
}

#pragma mark - Actions
- (IBAction)saveButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    BOOL previousSendingCrashReports = [JMUtils crashReportsSendingEnable];
    [self.detailSettings saveSettings];
    if (previousSendingCrashReports != [JMUtils crashReportsSendingEnable]) {
        [[UIAlertView localizedAlertWithTitle:@"detail.settings.crashtracking.alert.title" message:@"detail.settings.crashtracking.alert.message" delegate:self cancelButtonTitle:@"dialog.button.ok" otherButtonTitles: nil] show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
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

- (void)showIntroView
{
//    JMIntroViewController *introViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMIntroViewController"];
    JMOnboardIntroViewController *introViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMOnboardIntroViewController"];
    introViewController.view.backgroundColor = [UIColor colorWithPatternImage:[self.view renderedImageForView:self.navigationController.view]];
    [self presentViewController:introViewController animated:YES completion:nil];
}

#pragma mark - 
#pragma mrak - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
