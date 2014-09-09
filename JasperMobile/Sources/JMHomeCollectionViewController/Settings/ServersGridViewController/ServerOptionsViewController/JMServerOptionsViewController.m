//
//  JMServerOptionsViewController.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMServerOptionsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JMServerProfile+Helpers.h"
#import "JMServerOptions.h"

#import "ALToastView.h"

#import "UITableViewCell+Additions.h"
#import "JMServerOptionCell.h"
#import "UIAlertView+LocalizedAlert.h"


@interface JMServerOptionsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, JMServerOptionCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) JMServerOptions *serverOptions;

@end

@implementation JMServerOptionsViewController

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.serverProfile) {
        self.title = self.serverProfile.alias;
    } else {
        self.title = JMCustomLocalizedString(@"servers.title.new", nil);
    }

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"apply_item.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(saveButtonTapped:)];
    if (self.serverProfile && !self.serverProfile.serverProfileIsActive) {
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete_item.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(deleteButtonTapped:)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:saveButton, deleteButton, nil];
    } else {
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.tableView.layer.cornerRadius = 4;
    self.serverOptions = [[JMServerOptions alloc] initWithServerProfile:self.serverProfile];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.serverOptions discardChanges];
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
    [self.serverOptions setServerProfileActive];
    [self.navigationController popViewControllerAnimated:YES];
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
