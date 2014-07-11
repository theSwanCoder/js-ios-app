//
//  JMDetailSettingsViewController.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/9/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMDetailSettingsViewController.h"
#import "UITableViewCell+SetSeparators.h"
#import <QuartzCore/QuartzCore.h>
#import "JMLocalization.h"
#import "JMDetailSettingsTableViewCell.h"
#import "JMDetailSettings.h"
#import "JMActionBarProvider.h"
#import "JMDetailSettingsActionBarView.h"
#import "UIAlertView+LocalizedAlert.h"


@interface JMDetailSettingsViewController () <JMActionBarProvider, JMDetailSettingsActionBarViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (weak, nonatomic) IBOutlet UILabel *settingsTitleLabel;

@property (nonatomic, strong) JMDetailSettingsActionBarView *actionBarView;
@property (nonatomic, strong) JMDetailSettings *detailSettings;
@end

@implementation JMDetailSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.settingsTitleLabel.textColor = kJMDetailViewLightTextColor;
    self.settingsTableView.layer.cornerRadius = 4;

    self.settingsTitleLabel.text = [JMCustomLocalizedString(@"detail.settings.title", nil) uppercaseString];
    self.detailSettings = [[JMDetailSettings alloc] init];
    
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.detailSettings.itemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"settingsCellIdentifier";
    JMDetailSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[JMDetailSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setBottomSeparatorWithHeight:1 color:tableView.separatorColor tableViewStyle:tableView.style];
    }
    cell.settingsItem = [self.detailSettings.itemsArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - JMActionBarProvider
- (id)actionBar
{
    if (!self.actionBarView) {
        self.actionBarView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([JMDetailSettingsActionBarView class])
                                                           owner:self
                                                         options:nil].firstObject;
        self.actionBarView.delegate = self;
    }
    
    return self.actionBarView;
}

#pragma mark - JMDetailSettingsActionBarViewDelegate
- (void)saveButtonTappedInActionView:(JMDetailSettingsActionBarView *)actionView
{
    [self.detailSettings saveSettings];
    [[UIAlertView localizedAlertWithTitle:nil message:JMCustomLocalizedString(@"detail.settings.settings.saved", nil) delegate:self cancelButtonTitle:JMCustomLocalizedString(@"dialog.button.ok", nil) otherButtonTitles:JMCustomLocalizedString(@"dialog.button.cancel", nil), nil] show];
}

- (void)cancelButtonTappedInActionView:(JMDetailSettingsActionBarView *)actionView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
