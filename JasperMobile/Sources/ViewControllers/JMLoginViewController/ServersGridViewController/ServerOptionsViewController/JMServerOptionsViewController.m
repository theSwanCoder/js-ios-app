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


#import "JMServerOptionsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JMServerProfile+Helpers.h"
#import "JMServerOptions.h"

#import "ALToastView.h"

#import "UITableViewCell+Additions.h"
#import "JMServerOptionCell.h"

#import "JMCancelRequestPopup.h"


@interface JMServerOptionsViewController () <UITableViewDataSource, UITableViewDelegate, JMServerOptionCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) JMServerOptions *serverOptions;
@property (nonatomic, strong) JSRESTBase *restBase;
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
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.tableView.layer.cornerRadius = 4;
    if (!self.serverProfile) {
        self.serverOptions = [[JMServerOptions alloc] initWithServerProfile:nil];
    }
    self.serverOptions.editable = self.editable;
    self.tableView.rowHeight = 50.f;
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMServerOption *option = [self.serverOptions.optionsArray objectAtIndex:indexPath.row];
    if (option.errorString) {
        CGFloat maxWidth = tableView.frame.size.width - 30;
        CGSize maximumLabelSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
        CGRect textRect = [option.errorString boundingRectWithSize:maximumLabelSize
                                                           options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                        attributes:@{NSFontAttributeName:[JMFont tableViewCellDetailErrorFont]}
                                                           context:nil];
        return tableView.rowHeight + ceil(textRect.size.height);
    }
    return tableView.rowHeight;
}
#pragma mark - Actions

- (void)saveButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    if ([self.serverOptions isValidData]) {
        [self.serverOptions saveChanges];
        [self.navigationController popViewControllerAnimated:YES];

        if ([self.delegate respondsToSelector:@selector(serverProfileDidChanged:)]) {
            [self.delegate serverProfileDidChanged:self.serverProfile];
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

@end
