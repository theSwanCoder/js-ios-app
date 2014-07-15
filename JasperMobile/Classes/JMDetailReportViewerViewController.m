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

@synthesize inputControls = _inputControls; // A mutable array of "JSInputControlDescriptor" objects
@synthesize resourceLookup = _resourceLookup;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - JMActionBarProvider

- (id)actionBar
{
    // TODO: implement
    return nil;
}

#pragma mark - JMRefreshable

- (void)refresh
{
    
}

#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
