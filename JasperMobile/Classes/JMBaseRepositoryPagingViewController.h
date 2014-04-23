//
//  JMBaseRepositoryPagingViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/17/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMBaseRepositoryPagingViewController : UIViewController <UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *pageViewController;

@end
