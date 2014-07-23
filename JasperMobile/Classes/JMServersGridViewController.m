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
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern.png"]];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ServerProfile"];
    self.servers = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy] ?: [NSMutableArray array];
    
    for (JMServerProfile *serverProfile in self.servers) {
        [serverProfile setPasswordAsPrimitive:[JMServerProfile passwordFromKeychain:serverProfile.profileID]];
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

@end
