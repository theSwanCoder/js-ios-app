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
//  JMDetailViewController.m
//  Jaspersoft Corporation
//

#import "JMDetailViewController.h"
#import "JMConstants.h"
#import "JMPaginationData.h"
#import "JMRefreshable.h"

typedef enum {
    JMViewControllerTypeGrid = 1,
    JMViewControllerTypeHorizontal = 2,
    JMViewControllerTypeVertical = 3
} JMViewControllerType;

@interface JMDetailViewController ()
@property (nonatomic, assign) JMViewControllerType viewControllerType;
@property (nonatomic, weak) UINavigationController *activeDetailViewController;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, strong) NSMutableArray *switchButtons;
@property (nonatomic, strong) NSDictionary *viewControllerTypes;
@end

@implementation JMDetailViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.containerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern.png"]];
    self.resources = [NSMutableArray array];

    self.viewControllerTypes = @{
        @(JMViewControllerTypeGrid) : @"GridViewController",
        @(JMViewControllerTypeHorizontal) : @"ResourcesHorizontalListViewController",
        @(JMViewControllerTypeVertical) : @"ResourcesVerticalListViewController"
    };

    self.switchButtons = [NSMutableArray array];
    for (NSNumber *viewControllerType in self.viewControllerTypes.allKeys) {
        UIButton *switchButton = (UIButton *) [self.view viewWithTag:viewControllerType.integerValue];
        [self.switchButtons addObject:switchButton];
    }

    self.viewControllerType = JMViewControllerTypeHorizontal;
    [[self.switchButtons objectAtIndex:self.viewControllerType] setEnabled:NO];
    [self instantiateAndSetAsActiveViewControllerOfType:self.viewControllerType];

    [[NSNotificationCenter defaultCenter] addObserverForName:kJMPageLoadedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        JMPaginationData *paginationData = [note.userInfo objectForKey:kJMPaginationData];
        self.resources = paginationData.resources;
        self.hasNextPage = paginationData.hasNextPage;
        UIViewController <JMRefreshable> *baseRepositoryViewController = self.activeDetailViewController.viewControllers.firstObject;
        baseRepositoryViewController.needsToResetScroll = paginationData.isNewResourcesType;
        [baseRepositoryViewController refresh];
    }];
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

#pragma mark - Private

- (void)instantiateAndSetAsActiveViewControllerOfType:(JMViewControllerType)type
{
    NSString *identifier = [self.viewControllerTypes objectForKey:@(type)];

    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];

    // Remove from parent view
    if (self.activeDetailViewController) {
        [self.activeDetailViewController willMoveToParentViewController:nil];
        [[self.activeDetailViewController view] removeFromSuperview];
        [self.activeDetailViewController removeFromParentViewController];
    }

    CGSize containerViewSize = self.containerView.frame.size;
    CGRect frame = CGRectMake(0, 0, containerViewSize.width, containerViewSize.height);
    navigationController.view.frame = frame;
    [self addChildViewController:navigationController];
    [self.containerView addSubview:navigationController.view];
    [navigationController didMoveToParentViewController:self];

    self.activeDetailViewController = navigationController;

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

@end
