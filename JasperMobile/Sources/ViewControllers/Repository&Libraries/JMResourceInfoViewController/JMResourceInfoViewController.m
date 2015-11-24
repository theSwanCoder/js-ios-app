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


#import "JMResourceInfoViewController.h"
#import "JMFavorites+Helpers.h"
#import "UITableViewCell+Additions.h"
#import "JSResourceLookup+Helpers.h"
#import "PopoverView.h"
#import "JMSavedResources+Helpers.h"
#import "UIViewController+Additions.h"

NSString * const kJMShowResourceInfoSegue  = @"ShowResourceInfoSegue";

@interface JMResourceInfoViewController ()<UITableViewDataSource, UITableViewDelegate, PopoverViewDelegate>
@property (nonatomic, strong) NSArray *resourceProperties;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) PopoverView *popoverView;
@property (nonatomic, assign) BOOL needLayoutUI;
@property (nonatomic) UIDocumentInteractionController *documentController;
@end

@implementation JMResourceInfoViewController
@synthesize resourceLookup = _resourceLookup;

#pragma mark - UIViewController Life Cycle
- (instancetype)init
{
    return [self initWithNibName:@"JMResourceInfoViewController" bundle:[NSBundle mainBundle]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];

    [self showNavigationItems];
    [self resetResourceProperties];
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateIfNeeded];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Observers
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetResourceProperties) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationDidChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteMarkDidChanged:) name:kJMFavoritesDidChangedNotification object:nil];
}

- (void)resetResourceProperties
{
    self.title = self.resourceLookup.label;
    self.resourceProperties = nil;
    [self.tableView reloadData];
    self.needLayoutUI = YES;
}

- (void)interfaceOrientationDidChanged:(id)notification
{
    self.needLayoutUI = YES;
}

- (void)favoriteMarkDidChanged:(id)notification
{
    self.needLayoutUI = YES;
}

#pragma mark - Actions
- (void)favoriteButtonTapped:(id)sender
{
    if ([JMFavorites isResourceInFavorites:self.resourceLookup]) {
        [JMFavorites removeFromFavorites:self.resourceLookup];
    } else {
        [JMFavorites addToFavorites:self.resourceLookup];
    }
}

- (void)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public API
- (NSArray *)resourceProperties
{
    
    if (!_resourceProperties) {
        NSString *createdAtString = [JMUtils localizedStringFromDate:self.resourceLookup.creationDate];
        NSString *modifiedAtString = [JMUtils localizedStringFromDate:self.resourceLookup.updateDate];

        _resourceProperties = @[
                                @{
                                    kJMTitleKey : @"label",
                                    kJMValueKey : self.resourceLookup.label ?: @""
                                    },
                                @{
                                    kJMTitleKey : @"description",
                                    kJMValueKey : self.resourceLookup.resourceDescription ?: @""
                                    },
                                @{
                                    kJMTitleKey : @"uri",
                                    kJMValueKey : self.resourceLookup.uri ?: @""
                                    },
                                
                                @{
                                    kJMTitleKey : @"type",
                                    kJMValueKey : [self.resourceLookup localizedResourceType] ?: @""
                                    },
                                @{
                                    kJMTitleKey : @"version",
                                    kJMValueKey : self.resourceLookup.version ? [NSString stringWithFormat:@"%@", self.resourceLookup.version]: @""
                                    },
                                @{
                                    kJMTitleKey : @"creationDate",
                                    kJMValueKey : createdAtString ?: @""
                                    },
                                @{
                                    kJMTitleKey : @"modifiedDate",
                                    kJMValueKey : modifiedAtString ?: @""
                                    }
                                ];
    }
    return _resourceProperties;
}

- (JMMenuActionsViewAction)availableAction
{
    JMMenuActionsViewAction availableAction = JMMenuActionsViewAction_None;
    if (![self favoriteItemShouldDisplaySeparately]) {
        availableAction |= [self favoriteAction];
    }
    if ([self.resourceLookup isSavedReport]) {
        availableAction |= JMMenuActionsViewAction_OpenIn;
    }
    return availableAction;
}

#pragma mark - Private API
- (void)setNeedLayoutUI:(BOOL)needLayoutUI
{
    _needLayoutUI = needLayoutUI;
    [self updateIfNeeded];
}

- (void)updateIfNeeded
{
    if (self.needLayoutUI && [self isVisible]) {
        [self showNavigationItems];
        self.needLayoutUI = NO;
    }
}

- (JMMenuActionsViewAction)favoriteAction
{
    BOOL isResourceInFavorites = [JMFavorites isResourceInFavorites:self.resourceLookup];
    return isResourceInFavorites ? JMMenuActionsViewAction_MakeUnFavorite : JMMenuActionsViewAction_MakeFavorite;
}

#pragma mark - Setup Navigation Items
- (BOOL) favoriteItemShouldDisplaySeparately
{
    return (![JMUtils isCompactWidth] || ([JMUtils isCompactWidth] && [JMUtils isCompactHeight]));
}

- (void) showNavigationItems
{
    BOOL selfIsModalViewController = [self.navigationController.viewControllers count] == 1;
    if (selfIsModalViewController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(cancelButtonTapped:)];
        self.navigationItem.leftBarButtonItem.tintColor = [[JMThemesManager sharedManager] barItemsColor];
        self.navigationItem.rightBarButtonItem = [self favoriteBarButtonItem];
    } else {
        NSMutableArray *navBarItems = [NSMutableArray array];
        JMMenuActionsViewAction availableAction = [self availableAction];
        
        if (availableAction && (availableAction ^ [self favoriteAction])) {
            [navBarItems addObject:[self actionBarButtonItem]];
        } else if (![self favoriteItemShouldDisplaySeparately]) {
            [navBarItems addObject:[self favoriteBarButtonItem]];
        }
        
        if ([self favoriteItemShouldDisplaySeparately]) {
            [navBarItems addObject:[self favoriteBarButtonItem]];
        }
        
        self.navigationItem.rightBarButtonItems = navBarItems;
    }
}

- (UIBarButtonItem *) favoriteBarButtonItem
{
    BOOL isResourceInFavorites = [JMFavorites isResourceInFavorites:self.resourceLookup];
    NSString *imageName = isResourceInFavorites ? @"favorited_item" : @"make_favorite_item";
    
    UIBarButtonItem *favoriteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(favoriteButtonTapped:)];
    favoriteItem.tintColor = isResourceInFavorites ? [[JMThemesManager sharedManager] resourceViewResourceFavoriteButtonTintColor] : [[JMThemesManager sharedManager] barItemsColor];
    return favoriteItem;
}

- (UIBarButtonItem *) actionBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                         target:self
                                                         action:@selector(showAvailableActions)];
}

- (void)showAvailableActions
{
    JMMenuActionsView *actionsView = [JMMenuActionsView new];
    actionsView.delegate = self;
    actionsView.availableActions = [self availableAction];
    CGPoint point = CGPointMake(CGRectGetWidth(self.view.frame), -10);
    
    self.popoverView = [PopoverView showPopoverAtPoint:point
                                                inView:self.view
                                             withTitle:nil
                                       withContentView:actionsView
                                              delegate:self];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resourceProperties.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"ResourceAttributeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [[JMThemesManager sharedManager] tableViewCellTitleFont];
        cell.textLabel.textColor = [[JMThemesManager sharedManager] tableViewCellTitleTextColor];
        cell.detailTextLabel.font = [[JMThemesManager sharedManager] tableViewCellDetailFont];
        cell.detailTextLabel.textColor = [[JMThemesManager sharedManager] tableViewCellDetailsTextColor];
        cell.detailTextLabel.numberOfLines = 2;
    }
    
    if (indexPath.row) {
        [cell setTopSeparatorWithHeight:1.f color:tableView.separatorColor tableViewStyle:UITableViewStylePlain];
    }
    
    NSDictionary *item = self.resourceProperties[indexPath.row];
    cell.textLabel.text = JMCustomLocalizedString([NSString stringWithFormat:@"resource.%@.title", item[kJMTitleKey]], nil);
    cell.detailTextLabel.text = item[kJMValueKey];
    return cell;
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    switch (action) {
        case JMMenuActionsViewAction_MakeFavorite:
        case JMMenuActionsViewAction_MakeUnFavorite:
            [self favoriteButtonTapped:nil];
            break;
        case JMMenuActionsViewAction_OpenIn: {
            JMSavedResources *savedResources = [JMSavedResources savedReportsFromResourceLookup:self.resourceLookup];
            NSString *fullReportPath = [JMSavedResources absolutePathToSavedReport:savedResources];

            NSURL *url = [NSURL fileURLWithPath:fullReportPath];

            self.documentController = [self setupDocumentControllerWithURL:url
                                                             usingDelegate:nil];

            BOOL canOpen = [self.documentController presentOpenInMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
            if (!canOpen) {
                NSString *errorMessage = JMCustomLocalizedString(@"error.openIn.message", nil);
                NSError *error = [NSError errorWithDomain:@"dialod.title.error" code:NSNotFound userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
                [JMUtils presentAlertControllerWithError:error completion:nil];
            }
            break;
        }
        default:
            break;
    }
    
    [self.popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.2f];
}

#pragma mark - PopoverViewDelegate Methods
- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    self.popoverView = nil;
}

#pragma mark - Handle rotates
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    if (self.popoverView) {
        [self.popoverView dismiss:NO];
        [self showAvailableActions];
    }
}

#pragma mark - Helpers
- (UIDocumentInteractionController *) setupDocumentControllerWithURL: (NSURL *) fileURL
                                                       usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

@end
