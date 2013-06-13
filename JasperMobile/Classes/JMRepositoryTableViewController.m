//
//  JMRepositoryTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/5/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMRepositoryTableViewController.h"
#import "JMFilter.h"

@implementation JMRepositoryTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = self.resourceDescriptor.uriString ?: @"/";
    [JMFilter checkNetworkReachabilityForBlock:^{
        [self.resourceClient resources:path delegate:[JMFilter checkRequestResultForDelegate:self]];
    } viewControllerToDismiss:self];
}

@end
