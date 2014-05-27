//
//  JMSplitViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/18/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMSplitViewController.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kMasterViewWidth = 163.0f;

@interface JMSplitViewController()
@property (nonatomic, weak) UIView *shadow;
@property (nonatomic, weak) UIViewController *subMaster;
@end

@implementation JMSplitViewController

@synthesize selectedItem = _selectedItem;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _selectedItem = JMMenuItemHomeView;
        self.delegate = self;
    }
    
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    JMHomeCollectionViewController *homeView = [self.viewControllers objectAtIndex:1];
    homeView.delegate = self;
    
    UIViewController *masterViewController = [self.viewControllers objectAtIndex:0];
    UIButton *button = (UIButton *)[masterViewController.view viewWithTag:3];
    [button addTarget:self action:@selector(backToHomeScreen:) forControlEvents:UIControlEventTouchUpInside];

    // TODO: refactor
//    UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(kMasterViewWidth, 112.0f, 0, self.view.frame.size.height)];
//    shadow.layer.masksToBounds = NO;
//    shadow.layer.shadowColor = [[UIColor blackColor] CGColor];
//    shadow.layer.shadowOpacity = 0.6f;
//    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, 1, self.view.frame.size.height), NULL);
//    shadow.layer.shadowPath = path;
//    CGPathRelease(path);
//    [self.view addSubview:shadow];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIViewController *masterViewController = [self.viewControllers objectAtIndex:0];
    UIViewController *detailViewController = [self.viewControllers objectAtIndex:1];
    
    if (detailViewController.view.frame.origin.x > 0.0) {
        // Adjust the width of the master view
        CGRect masterViewFrame = masterViewController.view.frame;
        CGFloat deltaX = masterViewFrame.size.width - kMasterViewWidth;
        masterViewFrame.size.width -= deltaX;
        masterViewController.view.frame = masterViewFrame;
        
        // Adjust the width of the detail view
        CGRect detailViewFrame = detailViewController.view.frame;
        detailViewFrame.origin.x -= deltaX;
        detailViewFrame.size.width += deltaX;
        detailViewController.view.frame = detailViewFrame;
        
        [masterViewController.view setNeedsLayout];
        [detailViewController.view setNeedsLayout];
    }
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return self.selectedItem == JMMenuItemHomeView;
}

#pragma mark - JMHomeCollectionViewControllerDelegate

- (void)setSelectedItem:(JMMenuItem)selectedItem
{
    if (_selectedItem != selectedItem) {
        _selectedItem = selectedItem;

        NSString *subMasterIdentifier; // TODO: do we will need a detail here?
        NSString *menuTitle;
        
        // TODO: instantiate all view controllers
        switch (_selectedItem) {
            case JMMenuItemLibrary:
                subMasterIdentifier = @"MasterLibraryTableViewController";
                menuTitle = @"< Library";
                break;

            case JMMenuItemSavedReports:
                break;

            case JMMenuItemSettings:
                break;

            case JMMenuItemRepository:
                subMasterIdentifier = @"MasterRepositoryTableViewController";
                menuTitle = @"< Repository";
                break;

            case JMMenuItemFavorites:
                break;

            case JMMenuItemServerProfiles:
                break;
                
            case JMMenuItemHomeView:
            default:
                break;
        }
        
        // Remove previous detail view controller
        if (self.subMaster) {
            [self.subMaster willMoveToParentViewController:nil];
            [self.subMaster.view removeFromSuperview];
            [self.subMaster removeFromParentViewController];
        }
        
        UIViewController *master = [self.viewControllers objectAtIndex:0];
        UILabel *label = (UILabel *) [master.view viewWithTag:2];
        label.text = menuTitle;        
        
        id detail;
        
        if (_selectedItem != JMMenuItemHomeView) {
            UIView *masterContainer = [master.view viewWithTag:1];
            CGRect masterContainerFrame = masterContainer.frame;
        
            UIViewController *subMaster = [self.storyboard instantiateViewControllerWithIdentifier:subMasterIdentifier];
            CGRect subMasterFrame = CGRectMake(0, 0, masterContainerFrame.size.width, masterContainerFrame.size.height);
            subMaster.view.frame = subMasterFrame;
            
            [master addChildViewController:subMaster];
            [masterContainer addSubview:subMaster.view];
            [subMaster didMoveToParentViewController:master];
            
            self.subMaster = subMaster;
            
            detail = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
        } else {
            detail = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeCollectionViewController"];
            [detail setDelegate:self];
        }
        
        self.viewControllers = @[master, detail];
        
        // Forces to call splitViewController:shouldHideViewController:inOrientation: method
        [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
    }
}

#pragma mark - Actions

- (IBAction)backToHomeScreen:(id)sender
{
    self.selectedItem = JMMenuItemHomeView;
}

@end
