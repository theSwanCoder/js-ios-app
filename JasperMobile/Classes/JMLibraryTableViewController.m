//
//  JMLibraryTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/5/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMLibraryTableViewController.h"
#import "JMFilter.h"

#define kJMRequestType @"type"

@implementation JMLibraryTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *types = @[
       self.constants.WS_TYPE_REPORT_UNIT,
       self.constants.WS_TYPE_DASHBOARD
    ];
    [self.resourceClient resources:nil query:nil types:types recursive:YES limit:0 delegate:[JMFilter checkRequestResultForDelegate:self]];
}

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    id type = [result.request.params objectForKey:kJMRequestType];
    
    // Check if server supports dashboard type of resource (JasperServer CE version
    // doesn't have this type)
    if ([result isError] && [type isKindOfClass:[NSArray class]] &&
        [type containsObject:self.constants.WS_TYPE_DASHBOARD]) {
        NSArray *types = @[self.constants.WS_TYPE_REPORT_UNIT];
        
        [JMFilter checkNetworkReachabilityForBlock:^{
            [self.resourceClient resources:nil query:nil types:types recursive:YES limit:0 delegate:[JMFilter checkRequestResultForDelegate:self]];
        } viewControllerToDismiss:self];
    } else {
        [super requestFinished:result];
    }
}

@end
