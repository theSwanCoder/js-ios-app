/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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

static NSString * const kJMShowServerOptionsSegue = @"ShowServerOptions";

@interface JMServersGridViewController () <JMServerCollectionViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *servers;
@end

@implementation JMServersGridViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = JMCustomLocalizedString(@"servers.profile.title", nil);
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern"]];
    self.collectionView.backgroundColor = kJMMainCollectionViewBackgroundColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_item"] style:UIBarButtonItemStyleBordered  target:self action:@selector(addButtonTapped:)];
    
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
    self.servers = [[[JMUtils managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy] ?: [NSMutableArray array];
    [self.collectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    JMServerOptionsViewController *destinationViewController = segue.destinationViewController;
    if (sender) {
        [destinationViewController setServerProfile:sender];
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
    JMServerCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.serverProfile = [self.servers objectAtIndex:indexPath.row];
    cell.delegate = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __block BOOL requestDidCancelled = NO;
    [JMCancelRequestPopup presentWithMessage:@"status.loading" cancelBlock:^{
        requestDidCancelled = YES;
    }];
    
    JMServerProfile *serverProfile = [self.servers objectAtIndex:indexPath.row];
    [serverProfile checkServerProfileWithCompletionBlock:@weakself(^(NSError *error)) {
        if (!requestDidCancelled) {
            [JMCancelRequestPopup dismiss];
            if (error) {
                [[UIAlertView localizedAlertWithTitle:error.domain message:error.localizedDescription delegate:nil cancelButtonTitle:@"dialog.button.ok" otherButtonTitles:nil] show];
            } else {
                if ([self.delegate respondsToSelector:@selector(serverGridControllerDidSelectProfile:)]) {
                    [self.delegate serverGridControllerDidSelectProfile:serverProfile];
                }
            }
        }
    } @weakselfend];
}

// These methods provide support for copy/paste actions on cells.
// All three should be implemented if any are.
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(cloneServerProfile:) || action == @selector(deleteServerProfile:) || action == @selector(editServerProfile:)) {
        return YES;
    }
    return NO;
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
    [JMServerProfile cloneServerProfile:cell.serverProfile];
    [self refreshDatasource];
}

- (void)deleteServerProfileForCell:(JMServerCollectionViewCell *)cell
{
    [[UIAlertView localizedAlertWithTitle:nil
                                  message:@"servers.profile.delete.message"
                               completion:@weakself(^(UIAlertView *alertView, NSInteger buttonIndex)) {
                                   if (alertView.cancelButtonIndex != buttonIndex) {
                                       JMServerProfile *serverProfile = [self.servers objectAtIndex:[self.collectionView indexPathForCell:cell].row];
                                       [[JMUtils managedObjectContext] deleteObject:serverProfile];
                                       [[JMUtils managedObjectContext] save:nil];
                                       [self refreshDatasource];
                                   }
                               } @weakselfend
                        cancelButtonTitle:@"dialog.button.cancel"
                        otherButtonTitles:@"dialog.button.delete", nil] show];
}

-(void)editServerProfileForCell:(JMServerCollectionViewCell *)cell
{
    JMServerProfile *serverProfile = [self.servers objectAtIndex:[self.collectionView indexPathForCell:cell].row];
    [self performSegueWithIdentifier:kJMShowServerOptionsSegue sender:serverProfile];
}

#pragma mark - Actions
- (void)addButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:kJMShowServerOptionsSegue sender:nil];
}

@end
