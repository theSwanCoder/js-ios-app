//
//  JMDetailReportViewerViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/23/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMDetailReportViewerViewController.h"
#import "JMConstants.h"
#import <Objection-iOS/Objection.h>
#import "JMRequestDelegate.h"
#import "JMCancelRequestPopup.h"

@interface JMDetailReportViewerViewController ()

@property (nonatomic, weak) JSConstants *constants;

@end


@implementation JMDetailReportViewerViewController
objection_requires(@"resourceClient", @"reportClient", @"resourceLookup",  @"constants")
inject_default_rotation()

@synthesize resourceClient = _resourceClient;
@synthesize reportClient   = _reportClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize inputControls  = _inputControls; // A mutable array of "JSInputControlDescriptor" objects

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self runReportExecution];
}

- (void)runReportExecution
{
    __weak typeof(self) weakSelf = self;

    [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];

    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        [JMCancelRequestPopup dismiss];
        JSReportExecutionResponse *response = [result.objects objectAtIndex:0];
        JSExportExecution *export = [response.exports objectAtIndex:0];
        
        
        NSString *fullExportId = [NSString stringWithFormat:@"%@", export.uuid];
        NSString *reportUrl = [self.reportClient generateReportOutputUrl:response.requestId exportOutput:fullExportId];
        weakSelf.request = [NSURLRequest requestWithURL:[NSURL URLWithString:reportUrl]];
        
    } errorBlock:^(JSOperationResult *result) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } viewControllerToDismiss:self];
    
    NSMutableArray *parameters = [NSMutableArray array];
    for (JSInputControlDescriptor *inputControlDescriptor in self.inputControls) {
        JSReportParameter *reportParameter = [[JSReportParameter alloc] initWithName:inputControlDescriptor.uuid
                                                                               value:inputControlDescriptor.selectedValues];
        [parameters addObject:reportParameter];
    }

    [self.reportClient runReportExecution:self.resourceLookup.uri async:YES outputFormat:self.constants.CONTENT_TYPE_HTML
                              interactive:YES freshData:YES saveDataSnapshot:NO ignorePagination:NO transformerKey:nil
                                    pages:nil attachmentsPrefix:nil parameters:parameters delegate:delegate];
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
