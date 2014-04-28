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
#import "JMSwitchMenu.h"
#import "JMConstants.h"
#import "JMPaginationData.h"
#import "JMRefreshable.h"

typedef enum {
    JMViewControllerTypeHorizontal,
    JMViewControllerTypeVertical
} JMViewControllerType;

static NSString * const kJMHorizontalList = @"ResourcesCollectionViewController";
static NSString * const kJMVerticalList = @"ResourcesTableViewController";

@interface JMDetailViewController ()
@property (nonatomic, assign) JMViewControllerType viewControllerType;
@property (nonatomic, weak) UIViewController <JMRefreshable> *activeDetailViewController;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet JMSwitchMenu *switchBar;
@end

@implementation JMDetailViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.containerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_patter.png"]];
    self.resources = [NSMutableArray array];
    self.viewControllerType = JMViewControllerTypeHorizontal;
    [self instantiateAndSetAsActiveViewControllerOfType:self.viewControllerType];

    [[NSNotificationCenter defaultCenter] addObserverForName:kJMPageLoaded object:nil queue:nil usingBlock:^(NSNotification *note) {
        JMPaginationData *paginationData = [note.userInfo objectForKey:kJMPaginationData];
        self.resources = paginationData.resources;
        self.hasNextPage = paginationData.hasNextPage;
        self.activeDetailViewController.needsToResetScroll = paginationData.isNewResourcesType;
        [self.activeDetailViewController refresh];
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

- (IBAction)switchRepresentation:(id)sender
{
    switch ([sender selectedSegmentIndex]) {
        case 0:
            self.viewControllerType = JMViewControllerTypeHorizontal;
            break;
            
        case 1:
        default:
            self.viewControllerType = JMViewControllerTypeVertical;
            break;
    }
    
    [self instantiateAndSetAsActiveViewControllerOfType:self.viewControllerType];
}

#pragma mark - Private

- (void)setActiveViewController:(UIViewController <JMRefreshable> *)viewController
{
    // Remove from parent view
    if (self.activeDetailViewController) {
        [self.activeDetailViewController willMoveToParentViewController:nil];
        [[self.activeDetailViewController view] removeFromSuperview];
        [self.activeDetailViewController removeFromParentViewController];
    }

    CGSize containerViewSize = self.containerView.frame.size;
    CGRect frame = CGRectMake(0, 0, containerViewSize.width, containerViewSize.height);
    viewController.view.frame = frame;
    [self addChildViewController:viewController];
    [self.containerView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];

    self.activeDetailViewController = viewController;
}

- (void)instantiateAndSetAsActiveViewControllerOfType:(JMViewControllerType)type
{
    NSString *identifier;
    
    switch (type) {
        case JMViewControllerTypeVertical:
            identifier = kJMVerticalList;
            break;
            
        case JMViewControllerTypeHorizontal:
        default:
            identifier = kJMHorizontalList;
    }
    
    UIViewController <JMRefreshable> *viewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    if ([viewController respondsToSelector:@selector(setDelegate:)]) {
        [viewController performSelector:@selector(setDelegate:) withObject:self];
    }
    [self setActiveViewController:viewController];
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
