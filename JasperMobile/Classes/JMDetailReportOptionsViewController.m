//
//  JMDetailReportOptionsViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/7/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMDetailReportOptionsViewController.h"
#import "JMInputControlFactory.h"
#import "JMRequestDelegate.h"
#import <Objection-iOS/Objection.h>

@interface JMDetailReportOptionsViewController ()
@property (nonatomic, strong) JMInputControlFactory *inputControlFactory;
@end

@implementation JMDetailReportOptionsViewController
objection_requires(@"resourceClient", @"reportClient")

@synthesize resourceClient = _resourceClient;
@synthesize reportClient = _reportClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize inputControls = _inputControls;

- (JMInputControlFactory *)inputControlFactory
{
    if (!_inputControlFactory) {
        _inputControlFactory = [[JMInputControlFactory alloc] initWithViewController:self andTableView:self.tableView];
    }
    return _inputControlFactory;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Remove extra separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    // TODO: refactor, remove isKindOfClass: method usage
    if ([self.inputControls.firstObject isKindOfClass:JMInputControlCell.class]) return;

    NSArray *inputControlsData = [self.inputControls copy];
    [self.inputControls removeAllObjects];

    for (JSInputControlDescriptor *inputControlDescriptor in inputControlsData) {
        id cell = [self.inputControlFactory inputControlWithInputControlDescriptor:inputControlDescriptor];
        
        if ([cell conformsToProtocol:@protocol(JMResourceClientHolder)]) {
            [cell setResourceClient:self.resourceClient];
            [cell setResourceLookup:self.resourceLookup];
        }
        
        if ([cell conformsToProtocol:@protocol(JMReportClientHolder)]) {
            [cell setReportClient:self.reportClient];
        }
        
        [self.inputControls addObject:cell];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [JMRequestDelegate isRequestPoolEmpty] ? self.inputControls.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.inputControls objectAtIndex:indexPath.row];
}

@end
