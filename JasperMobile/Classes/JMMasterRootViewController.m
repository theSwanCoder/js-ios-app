//
//  JMMasterRootViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/29/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMMasterRootViewController.h"

@interface JMMasterRootViewController()
@property (nonatomic, weak) UIViewController *subMaster;
@end

@implementation JMMasterRootViewController

- (void)instantiateSubMasterViewControllerWithIdentifier:(NSString *)identifier
{
    CGRect masterContainerFrame = self.containerView.frame;

    UIViewController *subMaster = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    CGRect subMasterFrame = CGRectMake(0, 0, masterContainerFrame.size.width, masterContainerFrame.size.height);
    subMaster.view.frame = subMasterFrame;

    [self addChildViewController:subMaster];
    [self.containerView addSubview:subMaster.view];
    [subMaster didMoveToParentViewController:self];

    self.subMaster = subMaster;
}

- (void)removeSubMasterViewController
{
    if (self.subMaster) {
        [self.subMaster willMoveToParentViewController:nil];
        [self.subMaster.view removeFromSuperview];
        [self.subMaster removeFromParentViewController];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(back:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;

    [self.logoView addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - Actions

- (IBAction)back:(UITapGestureRecognizer *)recognizer
{
    [self.delegate setSelectedItem:JMMenuItemHomeView];
}

@end
