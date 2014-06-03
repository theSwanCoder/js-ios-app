/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2014 Jaspersoft Corporation. All rights reserved.
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

//
//  JMDetailRootViewController.m
//  Jaspersoft Corporation
//

#import "JMDetailRootViewController.h"
#import "JMConstants.h"
#import "JMRefreshable.h"
#import "JMRequestDelegate.h"
#import <Objection-iOS/Objection.h>

static NSInteger const kJMLimit = 15;

typedef enum {
    JMViewControllerTypeGrid = 2,
    JMViewControllerTypeHorizontal = 3,
    JMViewControllerTypeVertical = 4
} JMViewControllerType;

@interface JMDetailRootViewController ()
@property (nonatomic, strong) NSDictionary *viewControllerTypes;
// TODO: Replace list of buttons with UISwitch component
@property (nonatomic, strong) NSMutableArray *switchButtons;
@property (nonatomic, strong) NSArray *resourcesTypes;
@property (nonatomic, assign) JMViewControllerType viewControllerType;
@property (nonatomic, weak) UINavigationController *activeResourcesViewController;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@end

@implementation JMDetailRootViewController
objection_requires(@"resourceClient", @"constants")

@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize offset = _offset;
@synthesize totalCount = _totalCount;

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
    self.view.backgroundColor = [UIColor clearColor];
    self.containerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage
            imageNamed:@"list_background_pattern.png"]];
    
    self.resources = [NSMutableArray array];
    self.resourcesTypes = @[self.constants.WS_TYPE_REPORT_UNIT, self.constants.WS_TYPE_DASHBOARD];

    self.viewControllerTypes = @{
        @(JMViewControllerTypeGrid) : @"GridViewController",
        @(JMViewControllerTypeHorizontal) : @"ResourcesHorizontalListViewController",
        @(JMViewControllerTypeVertical) : @"ResourcesVerticalListViewController"
    };

    self.viewControllerType = JMViewControllerTypeHorizontal;
    self.switchButtons = [NSMutableArray array];
    for (NSNumber *viewControllerType in self.viewControllerTypes.allKeys) {
        UIButton *switchButton = (UIButton *) [self.view viewWithTag:viewControllerType.integerValue];
        [self.switchButtons addObject:switchButton];
        if (viewControllerType.integerValue == self.viewControllerType) {
            switchButton.enabled = NO;
        }
    }

    [self instantiateAndSetAsActiveViewControllerOfType:self.viewControllerType];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadResourcesInDetail:)
                                                 name:kJMLoadResourcesInDetail
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showResourcesListInDetail:)
                                                 name:kJMShowResourcesListInDetail
                                               object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    JSResourceLookup *resourceLookup = [self.resources objectAtIndex:[sender row]];
    [self showResourcesListInMaster:resourceLookup];
    
    // TODO: temp implementation, fix this
    JSRESTReport *reportClient = [[JSObjection defaultInjector] getObject:[JSRESTReport class]];
    
    NSURL *reportURL = [NSURL URLWithString:[reportClient generateReportUrl:resourceLookup.uri
                                                               reportParams:nil
                                                                       page:0
                                                                     format:self.constants.CONTENT_TYPE_PDF]];
    NSURLRequest *request = [NSURLRequest requestWithURL:reportURL];
    [segue.destinationViewController setRequest:request];
}

#pragma mark - UIViewControllerRotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Check if iOS 6 (edgesForExtendedLayout was added in iOS 7)
    if (![self.view respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self performSelector:@selector(fixRoundedSplitViewCorner) withObject:nil afterDelay:0];
    }
}

#pragma mark - Actions

- (IBAction)changeRepresentation:(id)sender
{
    for (UIButton *switchButton in self.switchButtons) {
        switchButton.enabled = YES;
    }
    [sender setEnabled:NO];

    self.viewControllerType = (JMViewControllerType) [sender tag];
    [self instantiateAndSetAsActiveViewControllerOfType:self.viewControllerType];
}

#pragma mark - Pagination

- (void)loadNextPage
{
    // Multiple calls protection
    static BOOL isLoading = NO;
    if (isLoading) return;
    
    __weak JMDetailRootViewController *weakSelf = self;

    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        isLoading = NO;

        UIViewController <JMRefreshable> *baseRepositoryViewController = weakSelf.activeResourcesViewController.viewControllers.firstObject;
        baseRepositoryViewController.needsToResetScroll = weakSelf.resources.count == 0;
        
        if (!weakSelf.totalCount) {
            weakSelf.totalCount = [[result.allHeaderFields objectForKey:@"Total-Count"] integerValue];
        }
        [weakSelf.resources addObjectsFromArray:result.objects];
        
        [baseRepositoryViewController refresh];
    } errorBlock:^(JSOperationResult *result) {
        isLoading = NO;
        weakSelf.offset -= kJMLimit;
        // TODO: add error handler
    }];

    [self.resourceClient resourceLookups:self.resourceLookup.uri query:nil types:self.resourcesTypes
                               recursive:self.loadRecursively offset:self.offset limit:kJMLimit delegate:delegate];
    
    isLoading = YES; 
    self.offset += kJMLimit;
}

- (BOOL)hasNextPage
{
    return self.offset < self.totalCount;
}

#pragma mark - Observer Methods

- (void)loadResourcesInDetail:(NSNotification *)notification
{
    // Reset state
    self.totalCount = 0;
    self.offset = 0;
    [self.resources removeAllObjects];

    NSDictionary *userInfo = notification.userInfo;
    if ([userInfo objectForKey:kJMResourcesTypes]) {
        self.resourcesTypes = [userInfo objectForKey:kJMResourcesTypes];
    }
    self.loadRecursively = [[userInfo objectForKey:kJMLoadRecursively] boolValue];
    self.resourceLookup = [userInfo objectForKey:kJMResourceLookup];

    [self loadNextPage];
}

- (void)showResourcesListInDetail:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    self.offset = [[userInfo objectForKey:kJMOffset] integerValue];
}

#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

- (void)instantiateAndSetAsActiveViewControllerOfType:(JMViewControllerType)type
{
    NSString *identifier = [self.viewControllerTypes objectForKey:@(type)];

    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];

    // Remove from parent view
    if (self.activeResourcesViewController) {
        [self.activeResourcesViewController willMoveToParentViewController:nil];
        [[self.activeResourcesViewController view] removeFromSuperview];
        [self.activeResourcesViewController removeFromParentViewController];
    }

    CGSize containerViewSize = self.containerView.frame.size;
    CGRect frame = CGRectMake(0, 0, containerViewSize.width, containerViewSize.height);
    navigationController.view.frame = frame;
    [self addChildViewController:navigationController];
    [self.containerView addSubview:navigationController.view];
    [navigationController didMoveToParentViewController:self];

    self.activeResourcesViewController = navigationController;

    UIViewController <JMRefreshable> *baseRepositoryViewController = [navigationController.viewControllers firstObject];
    if ([baseRepositoryViewController respondsToSelector:@selector(setDelegate:)]) {
        [baseRepositoryViewController performSelector:@selector(setDelegate:) withObject:self];
    }

    [baseRepositoryViewController refresh];
}

// Fixes rounded corners for split view controller
// Thanks to abs for the solution ( http://stackoverflow.com/a/2651876 )
- (void)fixRoundedSplitViewCorner
{
    [self explode:[[UIApplication sharedApplication] keyWindow] level:0];
}

- (void)explode:(id)view level:(NSNumber *)level
{
    if ([view isKindOfClass:[UIImageView class]]) {
        UIImageView *roundedCornerImage = (UIImageView *)view;
        roundedCornerImage.hidden = YES;
    }
    if (level.integerValue < 2) {
        for (UIView *subview in [view subviews]) {
            [self explode:subview level:@(level.integerValue + 1)];
        }
    }
}

- (void)showResourcesListInMaster:(JSResourceLookup *)resourceLookup
{
    NSDictionary *userInfo = @{
            kJMResources : self.resources,
            kJMTotalCount : @(self.totalCount),
            kJMOffset : @(self.offset),
            kJMResourceLookup : resourceLookup
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMShowResourcesListInMaster
                                                        object:nil
                                                      userInfo:userInfo];
}

@end
