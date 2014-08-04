//
//  JMServerOptionsViewController.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMServerOptionsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JMActionBarProvider.h"
#import "JMServerOptionsActionBarView.h"
#import "JMServerProfile+Helpers.h"
#import "JMServerOptions.h"
#import "JMTitleProvider.h"

#import "ALToastView.h"

#import "UITableViewCell+SetSeparators.h"
#import "JMServerOptionCell.h"
#import "JMLocalization.h"
#import "UIAlertView+LocalizedAlert.h"


@interface JMServerOptionsViewController () <JMActionBarProvider, JMBaseActionBarViewDelegate, JMTitleProvider, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *optionsTableView;
@property (nonatomic, strong) JMServerOptions *serverOptions;

@property (nonatomic, strong) JMServerOptionsActionBarView *actionBarView;

@end

@implementation JMServerOptionsViewController

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.optionsTableView.layer.cornerRadius = 4;
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

#pragma mark - JMActionBarProvider
- (id)actionBar
{
    if (!self.actionBarView) {
        NSString *actinBarNibName = NSStringFromClass([JMServerOptionsActionBarView class]);
        if (!self.serverProfile) {
            actinBarNibName = @"JMNewServerOptionsActionBarView";
        }
        
        self.actionBarView = [[NSBundle mainBundle] loadNibNamed:actinBarNibName
                                                           owner:self
                                                         options:nil].firstObject;
        self.actionBarView.delegate = self;
    }
    
    return self.actionBarView;
}

#pragma mark - JMDetailSettingsActionBarViewDelegate
- (void)actionView:(JMBaseActionBarView *)actionView didSelectAction:(JMBaseActionBarViewAction)action{
    [self.view endEditing:YES];
    switch (action) {
        case JMBaseActionBarViewAction_Cancel:
            [self.serverOptions discardChanges];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case JMBaseActionBarViewAction_Apply:
            if ([self.serverOptions saveChanges]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        case JMBaseActionBarViewAction_Delete:
            if (self.serverProfile.serverProfileIsActive) {
                [ALToastView toastInView:self.view withText:JMCustomLocalizedString(@"servers.activeserver.delete.errormessage", nil)];
            } else {
                [[UIAlertView localizedAlertWithTitle:nil
                                              message:@"servers.profile.delete.message"
                                             delegate:self
                                    cancelButtonTitle:@"dialog.button.cancel"
                                    otherButtonTitles:@"dialog.button.delete", nil] show];
            }
            break;
        case JMBaseActionBarViewAction_MakeActive:
            if (self.serverProfile.serverProfileIsActive) {
                [ALToastView toastInView:self.view withText:JMCustomLocalizedString(@"servers.activeserver.makeactive.errormessage", nil)];
            } else {
                [self.serverOptions setServerProfileActive];
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        default:
            //Unsupported actions
            break;
    }    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        [self.serverOptions deleteServerProfile];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - JMTitleProvider
- (NSString *)titleForMenuLabel
{
    NSString *keyString = self.serverProfile ? @"detail.servers.editserver" : @"detail.servers.newserver";
    return JMCustomLocalizedString(keyString, nil);
}
@end
