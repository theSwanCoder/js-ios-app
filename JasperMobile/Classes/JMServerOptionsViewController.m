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

#import "UITableViewCell+SetSeparators.h"
#import "JMServerOptionCell.h"
#import "JMLocalization.h"

@interface JMServerOptionsViewController () <JMActionBarProvider, JMBaseActionBarViewDelegate, JMTitleProvider>
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
        self.actionBarView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([JMServerOptionsActionBarView class])
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
        default:
            //Unsupported actions
            break;
    }    
}

#pragma mark - JMTitleProvider
- (NSString *)titleForMenuLabel
{
    NSString *keyString = self.serverProfile ? @"detail.servers.editserver" : @"detail.servers.newserver";
    return JMCustomLocalizedString(keyString, nil);
}
@end
