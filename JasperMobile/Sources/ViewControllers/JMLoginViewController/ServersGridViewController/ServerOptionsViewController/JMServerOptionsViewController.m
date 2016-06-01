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
#import "JMServerOptions.h"

#import "JMServerOptionCell.h"

#import "JMCancelRequestPopup.h"


@interface JMServerOptionsViewController () <UITableViewDataSource, UITableViewDelegate, JMServerOptionCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) JMServerOptions *serverOptions;
@property (nonatomic, strong) JSRESTBase *restBase;
@end

@implementation JMServerOptionsViewController
@dynamic serverProfile;

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.serverOptions.isExistingServerProfile) {
        self.title = self.serverProfile.alias;
    } else {
        self.title = JMCustomLocalizedString(@"servers_title_new", nil);
    }

    [self.saveButton setTitle:JMCustomLocalizedString(@"dialog_button_save", nil) forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[[JMThemesManager sharedManager] serverProfileSaveButtonTextColor] forState:UIControlStateNormal];
    self.saveButton.backgroundColor = [[JMThemesManager sharedManager] serverProfileSaveButtonBackgroundColor];
    
    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    self.tableView.layer.cornerRadius = 4;
    if (!self.serverProfile) {
        self.serverOptions = [[JMServerOptions alloc] initWithServerProfile:nil];
    }
    self.serverOptions.editable = self.editable;
    self.tableView.rowHeight = 50.f;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.serverOptions discardChanges];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

- (JMServerProfile *)serverProfile
{
    return self.serverOptions.serverProfile;
}

- (void)setServerProfile:(JMServerProfile *)serverProfile
{
    self.serverOptions = [[JMServerOptions alloc] initWithServerProfile:serverProfile];
    [self.tableView reloadData];
}

- (void)cancel
{
    if (self.exitBlock) {
        self.exitBlock();
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.serverOptions.optionsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMServerOption *option = self.serverOptions.optionsArray[indexPath.row];
    
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
    JMServerOption *option = self.serverOptions.optionsArray[indexPath.row];
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
    if ([self.serverOptions isValidData]) {
        // verify https scheme
        NSString *scheme = [self.serverOptions urlSchemeForServerProfile];
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
    [self.serverOptions saveChanges];
}

- (void)showSecurityHTTPAlert
{
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod_title_attention"
                                                                                      message:@"secutiry_http_message"
                                                                            cancelButtonTitle:@"dialog_button_ok"
                                                                      cancelCompletionHandler:^(UIAlertController *controller, UIAlertAction *action) {
                                                                          [self saveServerOptions];
                                                                          [self cancel];
                                                                      }];
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

@end
