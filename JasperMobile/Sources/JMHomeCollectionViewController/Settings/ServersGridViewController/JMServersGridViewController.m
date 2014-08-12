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
#import <Objection-iOS/Objection.h>
#import "JMServerCollectionViewCell.h"

static NSString * const kJMShowServerOptionsSegue = @"ShowServerOptions";

@interface JMServersGridViewController ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *servers;
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
    self.title = JMCustomLocalizedString(@"servers.profile.title", nil);
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern.png"]];
    self.collectionView.backgroundColor = kJMMainCollectionViewBackgroundColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_item.png"] style:UIBarButtonItemStyleBordered  target:self action:@selector(addButtonTapped:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshDatasource];

}

- (void) refreshDatasource
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ServerProfile"];
    self.servers = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy] ?: [NSMutableArray array];
    
    for (JMServerProfile *serverProfile in self.servers) {
        [serverProfile setPasswordAsPrimitive:[JMServerProfile passwordFromKeychain:serverProfile.profileID]];
    }
    [self.collectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
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
    JMServerCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.serverProfile = [self.servers objectAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    JMServerProfile *serverProfile = [self.servers objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:kJMShowServerOptionsSegue sender:serverProfile];
}

#pragma mark - Actions
- (IBAction)addButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:kJMShowServerOptionsSegue sender:nil];
}

@end
