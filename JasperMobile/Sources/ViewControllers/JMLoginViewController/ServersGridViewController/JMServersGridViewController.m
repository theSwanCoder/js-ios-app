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
    self.title = JMCustomLocalizedString(@"servers.profile.title", nil);
    self.view.backgroundColor = [[JMThemesManager sharedManager] serversViewBackgroundColor];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_item"] style:UIBarButtonItemStylePlain  target:self action:@selector(addButtonTapped:)];
    self.errorLabel.text = JMCustomLocalizedString(@"servers.profile.list.empty", nil);
    self.errorLabel.font = [[JMThemesManager sharedManager] resourcesActivityTitleFont];

    
    [[NSNotificationCenter defaultCenter] addObserver:self.collectionView selector:@selector(reloadData) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    UIMenuItem *editItem = [[UIMenuItem alloc] initWithTitle:JMCustomLocalizedString(@"servers.action.profile.edit", nil) action:@selector(editServerProfile:)];
    UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:JMCustomLocalizedString(@"servers.action.profile.delete", nil) action:@selector(deleteServerProfile:)];
    UIMenuItem *cloneItem = [[UIMenuItem alloc] initWithTitle:JMCustomLocalizedString(@"servers.action.profile.clone", nil) action:@selector(cloneServerProfile:)];

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
    JMServerOptionsViewController *destinationViewController = (JMServerOptionsViewController *) segue.destinationViewController;
    if (sender) {
        [destinationViewController setServerProfile:[sender objectForKey:kJMServerProfileKey]];
        destinationViewController.editable = [[sender objectForKey:kJMServerProfileEditableKey] boolValue];
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
    __block BOOL requestDidCancelled = NO;
    [JMCancelRequestPopup presentWithMessage:@"status.loading" cancelBlock:^{
        requestDidCancelled = YES;
    }];
    
    JMServerProfile *serverProfile = self.servers[indexPath.row];
    __weak typeof(self)weakSelf = self;
    [serverProfile checkServerProfileWithCompletionBlock:^(NSError *error) {
        __strong typeof(self)strongSelf = weakSelf;

        [JMCancelRequestPopup dismiss];
        if (!requestDidCancelled) {
            if (error) {
                [JMUtils presentAlertControllerWithError:error completion:nil];
            } else {
                // verify https scheme
                NSString *scheme = [NSURL URLWithString:serverProfile.serverUrl].scheme;
                BOOL isHTTPSScheme = [scheme isEqualToString:@"https"];
                if (isHTTPSScheme) {
                    if ([strongSelf.delegate respondsToSelector:@selector(serverGridControllerDidSelectProfile:)]) {
                        [strongSelf.delegate serverGridControllerDidSelectProfile:serverProfile];
                    }
                } else {
                    // show alert about http
                    [self showSecurityHTTPAlertForServerProfile:serverProfile];
                }

            }
        }
    }];
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
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod.title.confirmation"
                                                                                      message:@"servers.profile.delete.message"
                                                                            cancelButtonTitle:@"dialog.button.cancel"
                                                                      cancelCompletionHandler:nil];
    
    __weak typeof(self) weakSelf = self;
    [alertController addActionWithLocalizedTitle:@"dialog.button.delete" style:UIAlertActionStyleDefault handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
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
- (void)addButtonTapped:(id)sender
{
    NSDictionary *info = @{ kJMServerProfileEditableKey : @(YES)};
    [self performSegueWithIdentifier:kJMShowServerOptionsSegue sender:info];
}

#pragma mark - Helpers
- (void)showSecurityHTTPAlertForServerProfile:(JMServerProfile *)serverProfile
{
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod.title.attention"
                                                                                      message:@"secutiry.http.message"
                                                                            cancelButtonTitle:@"dialog.button.ok"
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
