//
//  JMDetailReportViewerViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/23/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMDetailReportViewerViewController.h"
#import "JMConstants.h"

@implementation JMDetailReportViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(back:)
                                                 name:kJMShowResourcesListInDetail
                                               object:nil];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)actionBar
{
    // Will remove action bar
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
