//
//  JMDetailReportOptionsViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/7/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMDetailReportOptionsViewController.h"
#import "JMRequestDelegate.h"
#import "JMDetailSingleSelectTableViewController.h"
#import "UIViewController+FetchInputControls.h"
#import <Objection-iOS/Objection.h>
#import "UITableViewCell+SetSeparators.h"

@interface JMDetailReportOptionsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) JSConstants *constants;

@end

@implementation JMDetailReportOptionsViewController
objection_requires(@"resourceClient", @"reportClient", @"constants")

@synthesize resourceClient = _resourceClient;
@synthesize reportClient = _reportClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize inputControls = _inputControls;

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
    self.titleLabel.text = JMCustomLocalizedString(@"detail.report.options.titlelabel.title", nil);
    self.titleLabel.textColor = kJMDetailViewLightTextColor;
    self.tableView.layer.cornerRadius = 4;
    
    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.tableView.layer.cornerRadius = 4;
    
    // Remove extra separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"apply_item.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(runReport)];
}

- (void)runReport
{
    BOOL allDataIsValid = YES;
    NSMutableArray *inputControlDescriptors = [NSMutableArray array];
    for (int i = 0; i < [self.inputControls count]; i++) {
        JSInputControlDescriptor *descriptor = [self.inputControls objectAtIndex:i];
        if (descriptor.validationRules.mandatoryValidationRule && descriptor.state.value == nil) {
            JMInputControlCell *cell = (JMInputControlCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell updateDisplayingOfErrorMessage: descriptor.validationRules.mandatoryValidationRule.errorMessage];
            allDataIsValid = NO;
        } else {
            [inputControlDescriptors addObject:descriptor];
        }
    }
    
    if (allDataIsValid) {
        if (!self.delegate) {
            [self performSegueWithIdentifier:kJMShowReportViewerSegue sender:inputControlDescriptors];
        } else {
            [self.delegate setInputControls:inputControlDescriptors];
            [self.delegate refresh];
        }
    } else {
        [self.tableView reloadData];
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
    JSInputControlDescriptor *inputControlDescriptor = [self.inputControls objectAtIndex:indexPath.row];
    
    NSString *cellIdentifier = [[self inputControlDescriptorTypes] objectForKey:inputControlDescriptor.type];
    JMInputControlCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setBottomSeparatorWithHeight:1 color:tableView.separatorColor tableViewStyle:tableView.style];
    [cell setInputControlDescriptor:inputControlDescriptor];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Private
// Returns input control types
- (NSDictionary *)inputControlDescriptorTypes
{
    return @{
             self.constants.ICD_TYPE_BOOL :                   @"BooleanCell",
             self.constants.ICD_TYPE_SINGLE_VALUE_TEXT :      @"TextEditCell",
             self.constants.ICD_TYPE_SINGLE_VALUE_NUMBER :    @"NumberCell",
             self.constants.ICD_TYPE_SINGLE_VALUE_DATE :      @"DateCell",
             self.constants.ICD_TYPE_SINGLE_VALUE_DATETIME :  @"DateTimeCell",
             self.constants.ICD_TYPE_SINGLE_SELECT :          @"SingleSelectCell",
             self.constants.ICD_TYPE_SINGLE_SELECT_RADIO :    @"SingleSelectCell",
             self.constants.ICD_TYPE_MULTI_SELECT :           @"MultiSelectCell",
             self.constants.ICD_TYPE_MULTI_SELECT_CHECKBOX :  @"MultiSelectCell",
             };
}

@end
