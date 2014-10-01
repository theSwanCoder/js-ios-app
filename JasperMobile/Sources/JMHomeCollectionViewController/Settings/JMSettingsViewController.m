//
//  JMSettingsViewController.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/9/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMSettingsViewController.h"
#import "UITableViewCell+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import "JMSettingsTableViewCell.h"
#import "JMSettings.h"
#import "UIAlertView+LocalizedAlert.h"
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
}

- (void)applicationInfo:(id)sender
{
    [[UIAlertView localizedAlertWithTitle:nil
                                  message:[NSString stringWithFormat:JMCustomLocalizedString(@"servers.info", nil), [JMAppUpdater latestAppVersionAsString]]
                                 delegate:nil
                        cancelButtonTitle:@"dialog.button.ok"
                        otherButtonTitles:nil] show];
}
@end
