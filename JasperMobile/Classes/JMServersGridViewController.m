//
//  JMServersGridViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/22/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMServersGridViewController.h"
#import "JMServerProfile.h"
#import "JMServerProfile+Helpers.h"
#import "JMActionBarProvider.h"
#import "JMServersActionBarView.h"
#import "JMLocalization.h"
#import <Objection-iOS/Objection.h>
#import "JMServerOptionsViewController.h"


static NSString * const kJMShowServerOptionsSegue = @"ShowServerOptions";

@interface JMServersGridViewController () <JMActionBarProvider, JMBaseActionBarViewDelegate, JMServerOptionsViewControllerDelegate>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *servers;
@property (nonatomic, strong) JMServersActionBarView *actionBarView;
@end

@implementation JMServersGridViewController
objection_requires(@"managedObjectContext")

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern.png"]];
    
    [self refreshDatasource];
}

- (void) refreshDatasource
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ServerProfile"];
    NSManagedObjectContext *context = [[JSObjection defaultInjector] getObject:[NSManagedObjectContext class]];
    
    self.servers = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy] ?: [NSMutableArray array];
    
    for (JMServerProfile *serverProfile in self.servers) {
        [serverProfile setPasswordAsPrimitive:[JMServerProfile passwordFromKeychain:serverProfile.profileID]];
    }
    [self.collectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    [destinationViewController setDelegate: self];
    if (sender) {
        [destinationViewController setServerProfile:sender];
    }
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.servers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ServerCell";
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    JMServerProfile *serverProfile = [self.servers objectAtIndex:indexPath.row];
    UILabel *alias = (UILabel *) [cell viewWithTag:1];
    UILabel *url = (UILabel *) [cell viewWithTag:2];
    alias.text = serverProfile.alias;
    url.text = serverProfile.serverUrl;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    JMServerProfile *serverProfile = [self.servers objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:kJMShowServerOptionsSegue sender:serverProfile];
}

#pragma mark - JMActionBarProvider

- (id)actionBar
{
    if (!self.actionBarView) {
        self.actionBarView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([JMServersActionBarView class])
                                                           owner:self
                                                         options:nil].firstObject;
        self.actionBarView.delegate = self;
    }
    
    return self.actionBarView;
}

#pragma mark - JMBaseActionBarViewDelegate

- (void)actionView:(JMBaseActionBarView *)actionView didSelectAction:(JMBaseActionBarViewAction)action
{
    if (action == JMBaseActionBarViewAction_Create) {
        [self performSegueWithIdentifier:kJMShowServerOptionsSegue sender:nil];
    }
}

#pragma mark - JMServerOptionsViewControllerDelegate

-(void)serverOptionsDidChanged{
    [self refreshDatasource];
}

@end
