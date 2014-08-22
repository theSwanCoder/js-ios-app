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
#import "JMDetailSingleSelectTableViewController.h"
#import "UIViewController+FetchInputControls.h"
#import <Objection-iOS/Objection.h>

@interface JMDetailReportOptionsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
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

    self.title = JMCustomLocalizedString(@"detail.report.options.title", nil);
    self.titleLabel.text = JMCustomLocalizedString(@"detail.report.options.title", nil);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.tableView.layer.cornerRadius = 4;
    
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
    UIBarButtonItem *runReportButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"apply_item.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(runReport)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel_item.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:runReportButton, cancelButton, nil];
}

- (void)cancel
{
    if (!self.delegate) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:kJMShowRootMaster object:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)runReport
{
    BOOL allDataIsValid = YES;
    NSMutableArray *inputControlDescriptors = [NSMutableArray array];
    for (JMInputControlCell *cell in self.inputControls) {
        if (cell.isValid) {
            [inputControlDescriptors addObject:cell.inputControlDescriptor];
        } else {
            allDataIsValid = NO;
        }
    }
    
    if (allDataIsValid) {
        if (!self.delegate) {
            [self performSegueWithIdentifier:kJMShowReportViewerSegue sender:inputControlDescriptors];
        } else {
            [self.delegate setInputControls:inputControlDescriptors];
            [self.delegate refresh];
        }
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

@end
