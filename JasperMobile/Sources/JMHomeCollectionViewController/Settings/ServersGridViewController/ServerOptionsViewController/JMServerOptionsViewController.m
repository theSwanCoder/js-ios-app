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


#import "JMServerOptionsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JMServerProfile+Helpers.h"
#import "JMServerOptions.h"

#import "ALToastView.h"

#import "UITableViewCell+Additions.h"
#import "JMServerOptionCell.h"
#import "UIAlertView+LocalizedAlert.h"

#import "JMRequestDelegate.h"
#import "JMCancelRequestPopup.h"


@interface JMServerOptionsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, JMServerOptionCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) JMServerOptions *serverOptions;

@end

@implementation JMServerOptionsViewController
@dynamic serverProfile;

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.serverProfile) {
        self.title = self.serverProfile.alias;
    } else {
        self.title = JMCustomLocalizedString(@"servers.title.new", nil);
    }

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"apply_item"] style:UIBarButtonItemStyleBordered target:self action:@selector(saveButtonTapped:)];
    if (self.serverProfile && !self.serverProfile.serverProfileIsActive) {
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete_item"] style:UIBarButtonItemStyleBordered target:self action:@selector(deleteButtonTapped:)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:saveButton, deleteButton, nil];
    } else {
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.tableView.layer.cornerRadius = 4;
    if (!self.serverProfile) {
        self.serverOptions = [[JMServerOptions alloc] initWithServerProfile:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.serverOptions discardChanges];
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

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.serverOptions.optionsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMServerOption *option = [self.serverOptions.optionsArray objectAtIndex:indexPath.row];
    
    JMServerOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:option.cellIdentifier];
    [cell setBottomSeparatorWithHeight:1 color:tableView.separatorColor tableViewStyle:tableView.style];
    cell.serverOption = option;
    return cell;
}

#pragma mark - Actions

- (void)saveButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    if ([self.serverOptions saveChanges]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.tableView reloadData];
    }
}

- (void)deleteButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    [[UIAlertView localizedAlertWithTitle:nil
                                  message:@"servers.profile.delete.message"
                                 delegate:self
                        cancelButtonTitle:@"dialog.button.cancel"
                        otherButtonTitles:@"dialog.button.delete", nil] show];
}

#pragma mark - JMServerOptionCellDelegate
- (void)makeActiveButtonTappedOnTableViewCell:(JMServerOptionCell *)cell
{
    [self.view endEditing:YES];
    JSProfile *profile = [[JSProfile alloc] initWithAlias:self.serverProfile.alias
                                                 username:self.serverProfile.username
                                                 password:self.serverProfile.password
                                             organization:self.serverProfile.organization
                                                serverUrl:self.serverProfile.serverUrl];
    void(^errorBlock)(JSOperationResult *result) = ^(JSOperationResult *result){
        [cell performSelector:@selector(discardActivityServer)];
    };
    
    JSRESTBase *restBase = [[JSRESTBase alloc] initWithProfile:profile classesForMappings:nil];
    [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:restBase cancelBlock:^{
        errorBlock(nil);
    }];
    
    __weak typeof(self) weakSelf = self;
    JMRequestDelegate *serverInfoDelegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        float serverVersion = restBase.serverInfo.versionAsFloat;
        if (serverVersion >= [JMServerProfile minSupportedServerVersion]) {
            [weakSelf.serverOptions setServerProfileActive];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            errorBlock(result);
            NSString *title = [NSString stringWithFormat:JMCustomLocalizedString(@"error.server.notsupported.title", nil), serverVersion];
            [[UIAlertView localizedAlertWithTitle:title
                                          message:@"error.server.notsupported.msg"
                                         delegate:nil
                                cancelButtonTitle:@"dialog.button.ok"
                                otherButtonTitles:nil] show];
        }
    } errorBlock:errorBlock];
    [restBase serverInfo:serverInfoDelegate];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        [self.serverOptions deleteServerProfile];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
