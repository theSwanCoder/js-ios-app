//
//  JMReportOptionsTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 8/19/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMReportOptionsTableViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMConstants.h"
#import "JMFilter.h"
#import "JMInputControlCell.h"
#import "JMInputControlFactory.h"
#import "JMSingleSelectTableViewController.h"
#import "JMRequestDelegate.h"
#import "JMUtils.h"
#import <Objection-iOS/Objection.h>

#define kJMICSection 0
#define kJMReportFormatSection 1
#define kJMRunReportSection 2

#define kJMRunCellIdentifier @"RunCell"
#define kJMShowSingleSelectSegue @"ShowSingleSelect"
#define kJMShowMultiSelectSegue @"ShowMultiSelect"

@implementation JMReportOptionsTableViewController
objection_requires(@"resourceClient", @"reportClient", @"constants")
inject_default_rotation()

@synthesize reportClient = _reportClient;
@synthesize resourceClient = _resourceClient;
@synthesize resourceDescriptor = _resourceDescriptor;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
    self.inputControls = [NSMutableArray array];
}

- (void)dealloc
{
    id defaultCenter = [NSNotificationCenter defaultCenter];

    for (JMInputControlCell *cell in self.inputControls) {
        [defaultCenter removeObserver:cell];
        [cell clearData];
    }

    self.inputControls = nil;
    self.resourceDescriptor = nil;
    self.resourceClient = nil;
    self.reportClient = nil;

    [JMRequestDelegate clearRequestPool];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [JMUtils setTitleForResourceViewController:self];
    if (self.resourceDescriptor) {
        [self updateInputControls];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kJMShowSingleSelectSegue] ||
        [segue.identifier isEqualToString:kJMShowMultiSelectSegue]) {
        [segue.destinationViewController setCell:sender];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == kJMICSection ? self.inputControls.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case kJMICSection:
            cell = [self.inputControls objectAtIndex:indexPath.row];
            break;
            
        // TODO: implement
        case kJMReportFormatSection: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SingleSelectCell"];
            break;
        }
            
        case kJMRunReportSection:
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:kJMRunCellIdentifier];
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
            UIButton *run = (UIButton *) [cell viewWithTag:1];
            [self configureRunButton:run];        
    }
    
    return cell;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return [self tableView:self.tableView viewForFooterInSection:section];
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
//    [view setBackgroundColor:[UIColor whiteColor]];
//    
//    return view;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == kJMICSection || section == kJMReportFormatSection) {
//        return 0.01f;
//    }
//    
//    return 10.0f;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0.001f;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kJMRunReportSection) return 50;
    
    if (self.inputControls.count > 0 && self.inputControls.count >= indexPath.row) {
        JMInputControlCell *cell = [self.inputControls objectAtIndex:indexPath.row];
        return cell.frame.size.height;
    }
    
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == kJMICSection && self.inputControls.count > 0) ? 12.0f : 1.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 8.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Private -
#pragma mark Configuration

- (void)configureRunButton:(UIButton *)button
{
    CGFloat corner = 18.0f;
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(corner, corner, corner, corner);
    
    UIImage *normal = [[UIImage imageNamed:@"run_report_button.png"] resizableImageWithCapInsets:edgeInsets];
    UIImage *highlighted = [[UIImage imageNamed:@"run_report_button_highlighted.png"] resizableImageWithCapInsets:edgeInsets];
    
    [button setBackgroundImage:normal forState:UIControlStateNormal];
    [button setBackgroundImage:highlighted forState:UIControlStateHighlighted];
}

- (void)createCellFromWrapper:(JSInputControlWrapper *)inputControl
{
    id cell = [self.inputControlFactory inputControlWithInputControlWrapper:inputControl];
    [self configureInputControlCell:cell];
    [self.inputControls addObject:cell];
}

- (void)createCellFromInputControlDescriptor:(JSInputControlDescriptor *)inputControl
{
    id cell = [self.inputControlFactory inputControlWithInputControlDescriptor:inputControl];
    [self configureInputControlCell:cell];
    [self.inputControls addObject:cell];
}

- (JMInputControlFactory *)inputControlFactory
{
    static JMInputControlFactory *inputControlFactory;
    if (!inputControlFactory || !inputControlFactory.tableViewController) inputControlFactory = [[JMInputControlFactory alloc] initWithTableViewController:self];
    return inputControlFactory;
}

- (void)configureInputControlCell:(id)cell
{
    if ([cell conformsToProtocol:@protocol(JMResourceClientHolder)]) {
        [cell setResourceClient:self.resourceClient];
        [cell setResourceDescriptor:self.resourceDescriptor];
    }

    if ([cell conformsToProtocol:@protocol(JMReportClientHolder)]) {
        [cell setReportClient:self.reportClient];
    }
}

#pragma mark Input Controls

- (void)updateInputControls
{
    JMCancelRequestBlock cancelBlock = ^{
        [JMRequestDelegate clearRequestPool];
        [self.navigationController popViewControllerAnimated:YES];
    };    

    if (self.reportClient.serverProfile.serverInfo.versionAsInteger >= self.constants.VERSION_CODE_EMERALD) {
        [JMFilter checkNetworkReachabilityForBlock:^{
            [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.reportClient cancelBlock:cancelBlock];
            [self.reportClient inputControlsForReport:self.resourceDescriptor.uriString delegate:self.inputControlsForReportDelegate];
        } viewControllerToDismiss:self];
        
    } else {
        [JMFilter checkNetworkReachabilityForBlock:^{
            [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:cancelBlock];
            [self.resourceClient resource:self.resourceDescriptor.uriString delegate:self.resourceDelegate];
        } viewControllerToDismiss:self];
    }
}

- (void)cleanupDependencies:(NSArray *)inputControls
{
    for (JSInputControlWrapper *inputControl in inputControls) {
        NSArray *slaveDependencies = inputControl.getSlaveDependencies;
        NSMutableArray *subDependentControls = [NSMutableArray array];

        // Collect all sub dependent controls
        for (JSInputControlWrapper *dependentControl in slaveDependencies) {
            [subDependentControls addObjectsFromArray:[self allSubDependentControls:dependentControl]];
        }

        // Remove controls that have transitive dependencies
        for (JSInputControlWrapper *subDependentControl in subDependentControls) {
            [inputControl removeSlaveDependency:subDependentControl];
        }
    }
}

- (NSArray *)allSubDependentControls:(JSInputControlWrapper *)inputControl
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *dependentControls = inputControl.getSlaveDependencies;
    
    // Collect recursively dependent controls if it is not empty
    if (dependentControls) {
        [result addObjectsFromArray:dependentControls];
        for (JSInputControlWrapper *dependentControl in dependentControls) {
            [result addObjectsFromArray:[self allSubDependentControls:dependentControl]];
        }
    }
    
    return result;
}

#pragma mark Rest v1 Request Finished Blocks

- (id <JSRequestDelegate>)resourceDelegate
{
    __weak JMReportOptionsTableViewController *reportOptions = self;
    
    // Will be invoked in the end after all requests will finish 
    [JMRequestDelegate setFinalBlock:^{
        [reportOptions.tableView reloadData];
        [JMCancelRequestPopup dismiss];
    }];
    
    return [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        reportOptions.resourceDescriptor = [result.objects objectAtIndex:0];
        
        NSMutableArray *inputControlWrappers = [NSMutableArray array];
        
        // Create wrapper for IC
        for (JSResourceDescriptor *childResourceDescriptor in reportOptions.resourceDescriptor.childResourceDescriptors) {
            if ([childResourceDescriptor.wsType isEqualToString:reportOptions.constants.WS_TYPE_INPUT_CONTROL]){
                JSInputControlWrapper *inputControl = [[JSInputControlWrapper alloc] initWithResourceDescriptor:childResourceDescriptor];
                [inputControlWrappers addObject:inputControl];
            }
        }
        
        // Update dependencies for IC
        for (JSInputControlWrapper *i in inputControlWrappers) {
            for (NSString *parameter in i.parameterDependencies) {
                for (JSInputControlWrapper *j in inputControlWrappers) {
                    if (j != i && [j.name isEqualToString:parameter]) {
                        [j addSlaveDependency:i];
                        [i addMasterDependency:j];
                    }
                }
            }
        }
        
        [reportOptions cleanupDependencies:inputControlWrappers];
        
        for (JSInputControlWrapper *inputControl in inputControlWrappers) {
            if (!inputControl.dataType && inputControl.dataTypeUri.length > 0) {
                [reportOptions requestDataTypeForInputControlWrapper:inputControl];
            } else {
                [reportOptions createCellFromWrapper:inputControl];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kJMUpdateInputControlQueryDataNotification
                                                            object:nil];
    }];
}

- (void)requestDataTypeForInputControlWrapper:(JSInputControlWrapper *)inputControlWrapper;
{
    // Define self with __weak modifier (require to avoid circular references and for
    // proper memory management)
    __weak JMReportOptionsTableViewController *reportOptions = self;
    __weak JSInputControlWrapper *inputControl = inputControlWrapper;
    
    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        JSResourceDescriptor *dataType = [result.objects objectAtIndex:0];
        JSResourceProperty *dataTypeProperty = [dataType propertyByName:reportOptions.constants.PROP_DATATYPE_TYPE];
        [inputControl setDataType:dataTypeProperty.value.intValue];
        [reportOptions createCellFromWrapper:inputControl];
    }];
    
    [self.resourceClient resource:inputControlWrapper.dataTypeUri delegate:delegate];
}

#pragma mark Rest v2 Request Finished Blocks

- (JMRequestDelegate *)inputControlsForReportDelegate
{
    __weak JMReportOptionsTableViewController *reportOptions = self;

    return [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        for (JSInputControlDescriptor *inputControlDescriptor in result.objects) {
            [reportOptions createCellFromInputControlDescriptor:inputControlDescriptor];
        }

        [reportOptions.tableView reloadData];
    }];
}

@end
