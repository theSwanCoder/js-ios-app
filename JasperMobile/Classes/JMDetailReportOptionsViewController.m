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
#import "JMDetailReportOptionsActionBarView.h"
#import "JMDetailSingleSelectTableViewController.h"
#import "UIViewController+FetchInputControls.h"
#import <Objection-iOS/Objection.h>

@interface JMDetailReportOptionsViewController () <JMBaseActionBarViewDelegate>
@property (nonatomic, strong) JMInputControlFactory *inputControlFactory;
@end

@implementation JMDetailReportOptionsViewController
objection_requires(@"resourceClient", @"reportClient")

@synthesize resourceClient = _resourceClient;
@synthesize reportClient = _reportClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize inputControls = _inputControls;

#pragma mark - Accessors

- (JMInputControlFactory *)inputControlFactory
{
    if (!_inputControlFactory) {
        _inputControlFactory = [[JMInputControlFactory alloc] initWithViewController:self andTableView:self.tableView];
    }
    return _inputControlFactory;
}

#pragma mark - JMDetailReportOptionsViewController

- (void)cancel
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kJMShowRootMaster object:nil];
    [center postNotificationName:kJMShowResourcesListInDetail object:nil];
}

- (void)runReport
{
    NSMutableArray *inputControlDescriptors = [NSMutableArray array];
    for (JMInputControlCell *cell in self.inputControls) {
        [inputControlDescriptors addObject:cell.inputControlDescriptor];
    }

    if (!self.delegate) {
        [self performSegueWithIdentifier:kJMShowReportViewerSegue sender:inputControlDescriptors];
    } else {
        [self.delegate setInputControls:inputControlDescriptors];
        [self.delegate refresh];
    }
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    
    if ([self isReportSegue:segue]) {
        [destinationViewController setResourceLookup:self.resourceLookup];
        [destinationViewController setInputControls:sender];
        self.delegate = destinationViewController;
    } else {
        [destinationViewController setCell:sender];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.inputControls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.inputControls objectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - JMActionBarProvider

- (id)actionBar
{
    JMDetailReportOptionsActionBarView *actionBar = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass
            ([JMDetailReportOptionsActionBarView class])
                                                                                  owner:self
                                                                                options:nil].firstObject;
    actionBar.delegate = self;
    return actionBar;
}

#pragma mark - JMBaseActionBarViewDelegate
- (void)actionView:(JMBaseActionBarView *)actionView didSelectAction:(JMBaseActionBarViewAction)action{
    switch (action) {
        case JMBaseActionBarViewAction_Cancel:
            [self cancel];
            break;
        case JMBaseActionBarViewAction_Run:
            [self runReport];
            break;
        default:
            // Unsupported actions
            break;
    }
}

@end
