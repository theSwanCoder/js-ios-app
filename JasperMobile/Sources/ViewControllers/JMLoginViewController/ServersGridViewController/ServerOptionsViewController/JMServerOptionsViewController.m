/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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


#import "JMServerOptionsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JMServerProfile+Helpers.h"
#import "JMServerOptionManager.h"

#import "JMServerOptionCell.h"

#import "JMCancelRequestPopup.h"
#import "JMLocalization.h"
#import "JMThemesManager.h"
#import "UIAlertController+Additions.h"
#import "NSObject+Additions.h"


@interface JMServerOptionsViewController () <UITableViewDataSource, UITableViewDelegate, JMServerOptionCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) JMServerOptionManager *serverOptionManager;
@property (nonatomic, copy) NSArray <JMServerOption *>*serverOptions;
@property (nonatomic, strong) JSRESTBase *restBase;
@end

@implementation JMServerOptionsViewController
@dynamic serverProfile;

#pragma mark - UIViewController Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *accessibilityLabelString;
    if (self.serverOptionManager.isExistingServerProfile) {
        self.title = self.serverProfile.alias;
        accessibilityLabelString = @"servers_title_edit";
    } else {
        self.title = JMLocalizedString(@"servers_title_new");
        accessibilityLabelString = @"servers_title_new";
    }
    [self.view setAccessibility:NO withTextKey:accessibilityLabelString identifier:JMNewServerProfilePageAccessibilityId];
    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];

    [self setupSaveButton];
    [self setupTableView];
    [self setupServerOptions];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.serverOptionManager discardChanges];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

#pragma mark - Setups
- (void)setupTableView
{
    self.tableView.layer.cornerRadius = 4;
    if (!self.serverProfile) {
        self.serverOptionManager = [[JMServerOptionManager alloc] initWithServerProfile:nil];
    }
    self.tableView.rowHeight = 50.f;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)setupSaveButton
{
    [self.saveButton setTitle:JMLocalizedString(@"dialog_button_save") forState:UIControlStateNormal];
    [self.saveButton setAccessibility:YES withTextKey:@"dialog_button_save" identifier:JMNewServerProfilePageSaveAccessibilityId];
    [self.saveButton setTitleColor:[[JMThemesManager sharedManager] serverProfileSaveButtonTextColor] forState:UIControlStateNormal];
    self.saveButton.backgroundColor = [[JMThemesManager sharedManager] serverProfileSaveButtonBackgroundColor];
}

- (void)setupServerOptions
{
    self.serverOptionManager.editable = self.editable;

    NSMutableArray *serverOptions = [NSMutableArray array];
    [serverOptions addObject:self.serverOptionManager.availableOptions[@(JMServerOptionTypeAlias)]];
    [serverOptions addObject:self.serverOptionManager.availableOptions[@(JMServerOptionTypeURL)]];
    [serverOptions addObject:self.serverOptionManager.availableOptions[@(JMServerOptionTypeOrganization)]];
    [serverOptions addObject:self.serverOptionManager.availableOptions[@(JMServerOptionTypeAskPassword)]];
    [serverOptions addObject:self.serverOptionManager.availableOptions[@(JMServerOptionTypeKeepSession)]];
#ifndef  __RELEASE__
    [serverOptions addObject:self.serverOptionManager.availableOptions[@(JMServerOptionTypeUseVisualize)]];
    [serverOptions addObject:self.serverOptionManager.availableOptions[@(JMServerOptionTypeCacheReports)]];
#endif
    self.serverOptions = serverOptions;
}

#pragma mark - Custom Accessors

- (JMServerProfile *)serverProfile
{
    return self.serverOptionManager.serverProfile;
}

- (void)setServerProfile:(JMServerProfile *)serverProfile
{
    self.serverOptionManager = [[JMServerOptionManager alloc] initWithServerProfile:serverProfile];
    [self.tableView reloadData];
}

#pragma mark - Public API

- (void)cancel
{
    if (self.exitBlock) {
        self.exitBlock();
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.serverOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMServerOption *option = self.serverOptions[indexPath.row];
    
    JMServerOptionCell *cell = (JMServerOptionCell *) [tableView dequeueReusableCellWithIdentifier:option.cellIdentifier];
    cell.serverOption = option;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMServerOption *option = self.serverOptions[indexPath.row];
    if (option.errorString) {
        CGFloat maxWidth = tableView.frame.size.width - 30;
        CGSize maximumLabelSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
        CGRect textRect = [option.errorString boundingRectWithSize:maximumLabelSize
                                                           options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                        attributes:@{NSFontAttributeName:[[JMThemesManager sharedManager] tableViewCellErrorFont]}
                                                           context:nil];
        return tableView.rowHeight + ceilf(textRect.size.height);
    }
    return tableView.rowHeight;
}
#pragma mark - Actions

- (IBAction)saveButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    if ([self.serverOptionManager isValidData]) {
        // verify https scheme
        NSString *scheme = [self.serverOptionManager urlSchemeForServerProfile];
        BOOL isHTTPSScheme = [scheme isEqualToString:@"https"];
        if (isHTTPSScheme) {
            [self saveServerOptions];
            [self cancel];
        } else {
            // show alert
            [self showSecurityHTTPAlert];
        }
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark - JMServerOptionCellDelegate
- (void)reloadTableViewCell:(JMServerOptionCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Helpers
- (void)saveServerOptions
{
    // save in DB current profile with updated properties
    [self.serverOptionManager saveChanges];
}

- (void)showSecurityHTTPAlert
{
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod_title_attention"
                                                                                      message:@"secutiry_http_message"
                                                                            cancelButtonType:JMAlertControllerActionType_Ok
                                                                      cancelCompletionHandler:^(UIAlertController *controller, UIAlertAction *action) {
                                                                          [self saveServerOptions];
                                                                          [self cancel];
                                                                      }];
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

@end
