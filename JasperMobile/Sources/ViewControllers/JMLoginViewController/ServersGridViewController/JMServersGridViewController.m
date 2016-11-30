/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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


#import "JMServersGridViewController.h"
#import "JMServerProfile.h"
#import "JMServerProfile+Helpers.h"
#import "JMServerCollectionViewCell.h"
#import "JMServerOptionsViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMLocalization.h"
#import "JMThemesManager.h"
#import "JMCoreDataManager.h"
#import "JMConstants.h"
#import "UIAlertController+Additions.h"

NSString * const kJMShowServerOptionsSegue = @"ShowServerOptions";
NSString * const kJMServerProfileEditableKey = @"kJMServerProfileEditableKey";

@interface JMServersGridViewController () <JMServerCollectionViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *servers;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;

@end

@implementation JMServersGridViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = JMLocalizedString(@"servers_profile_title");
    self.view.backgroundColor = [[JMThemesManager sharedManager] serversViewBackgroundColor];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.errorLabel.text = JMLocalizedString(@"servers_profile_list_empty");
    self.errorLabel.font = [[JMThemesManager sharedManager] resourcesActivityTitleFont];

    
    [[NSNotificationCenter defaultCenter] addObserver:self.collectionView selector:@selector(reloadData) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    UIMenuItem *editItem = [[UIMenuItem alloc] initWithTitle:JMLocalizedString(@"servers_action_profile_edit") action:@selector(editServerProfile:)];
    UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:JMLocalizedString(@"servers_action_profile_delete") action:@selector(deleteServerProfile:)];
    UIMenuItem *cloneItem = [[UIMenuItem alloc] initWithTitle:JMLocalizedString(@"servers_action_profile_clone") action:@selector(cloneServerProfile:)];

    [[UIMenuController sharedMenuController] setMenuItems:@[editItem, deleteItem, cloneItem]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshDatasource];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.collectionView];
}

- (void) refreshDatasource
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ServerProfile"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"self != %@", [JMServerProfile demoServerProfile]];
    
    self.servers = [[[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy] ?: [NSMutableArray array];
    self.errorLabel.hidden = [self.servers count];
    [self.collectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    JMServerOptionsViewController *destinationViewController = segue.destinationViewController;
    if (sender) {
        [destinationViewController setServerProfile:[sender objectForKey:kJMServerProfileKey]];
        destinationViewController.editable = [[sender objectForKey:kJMServerProfileEditableKey] boolValue];
        __weak __typeof(destinationViewController) weakVC = destinationViewController;
        destinationViewController.exitBlock = ^{
            __typeof(destinationViewController) strongVC = weakVC;
            [strongVC.navigationController popViewControllerAnimated:YES];
        };
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (self.isViewLoaded && self.view.window) {
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.servers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ServerCell";
    JMServerCollectionViewCell *cell = (JMServerCollectionViewCell *) [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.serverProfile = self.servers[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(serverGridControllerDidSelectProfile:)]) {
        [self.delegate serverGridControllerDidSelectProfile:self.servers[indexPath.row]];
    }
}

// These methods provide support for copy/paste actions on cells.
// All three should be implemented if any are.
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return action == @selector(cloneServerProfile:) || action == @selector(deleteServerProfile:);
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    
}

#pragma mark - UICollectionViewFlowLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *flowLayout = (id)collectionView.collectionViewLayout;
    return CGSizeMake(collectionView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right, flowLayout.itemSize.height);
}

#pragma mark - JMServerCollectionViewCellDelegate
- (void)cloneServerProfileForCell:(JMServerCollectionViewCell *)cell
{
    JMServerProfile *newServerProfile = [JMServerProfile cloneServerProfile:cell.serverProfile];
    NSDictionary *info = @{kJMServerProfileKey : newServerProfile,
                           kJMServerProfileEditableKey : @(YES)};
    [self performSegueWithIdentifier:kJMShowServerOptionsSegue sender:info];
}

- (void)deleteServerProfileForCell:(JMServerCollectionViewCell *)cell
{
    JMServerProfile *serverProfile = cell.serverProfile;
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod_title_confirmation"
                                                                                      message:@"servers_profile_delete_message"
                                                                            cancelButtonTitle:@"dialog_button_cancel"
                                                                      cancelCompletionHandler:nil];
    
    __weak typeof(self) weakSelf = self;
    [alertController addActionWithLocalizedTitle:@"dialog_button_delete" style:UIAlertActionStyleDefault handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
        __strong typeof(self) strongSelf = weakSelf;
        [JMServerProfile deleteServerProfile:serverProfile];
        [strongSelf refreshDatasource];
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)editServerProfileForCell:(JMServerCollectionViewCell *)cell
{
    NSDictionary *info = @{kJMServerProfileKey : cell.serverProfile,
                           kJMServerProfileEditableKey : @(NO)};
    [self performSegueWithIdentifier:kJMShowServerOptionsSegue sender:info];
}

#pragma mark - Actions
- (IBAction)addButtonTapped:(id)sender
{
    NSDictionary *info = @{ kJMServerProfileEditableKey : @(YES)};
    [self performSegueWithIdentifier:kJMShowServerOptionsSegue sender:info];
}

#pragma mark - Helpers
- (void)showSecurityHTTPAlertForServerProfile:(JMServerProfile *)serverProfile
{
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod_title_attention"
                                                                                      message:@"secutiry_http_message"
                                                                            cancelButtonTitle:@"dialog_button_ok"
                                                                      cancelCompletionHandler:^(UIAlertController *controller, UIAlertAction *action) {
                                                                          if ([self.delegate respondsToSelector:@selector(serverGridControllerDidSelectProfile:)]) {
                                                                              [self.delegate serverGridControllerDidSelectProfile:serverProfile];
                                                                          }
                                                                      }];
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

@end
