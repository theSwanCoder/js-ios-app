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
#import "JMDetailReportViewerActionBarView.h"
#import "UIViewController+FetchInputControls.h"
#import "JMFullScreenButtonProvider.h"


@interface JMDetailReportViewerViewController () <JMBaseActionBarViewDelegate, JMFullScreenButtonProvider>

@property (nonatomic, weak) JSConstants *constants;
@property (nonatomic, strong) JMDetailReportViewerActionBarView *actionBarView;

@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, strong) NSString *uuid;
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

- (void) runReportExecution
{
    __weak typeof(self) weakSelf = self;
    
    [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        JSReportExecutionResponse *response = [result.objects objectAtIndex:0];
        JSExportExecution *export = [response.exports objectAtIndex:0];
        weakSelf.uuid = export.uuid;
        weakSelf.requestId = response.requestId;
        
        NSString *reportUrl = [self.reportClient generateReportOutputUrl:weakSelf.requestId exportOutput:weakSelf.uuid];
        weakSelf.request = [NSURLRequest requestWithURL:[NSURL URLWithString:reportUrl]];
        
    } errorBlock: nil
                                                           viewControllerToDismiss:self];
    
    NSMutableArray *parameters = [NSMutableArray array];
    for (JSInputControlDescriptor *inputControlDescriptor in self.inputControls) {
        JSReportParameter *reportParameter = [[JSReportParameter alloc] initWithName:inputControlDescriptor.uuid
                                                                               value:inputControlDescriptor.selectedValues];
        [parameters addObject:reportParameter];
    }
    
    [self.reportClient runReportExecution:self.resourceLookup.uri async:YES outputFormat:self.constants.CONTENT_TYPE_HTML
                              interactive:YES freshData:YES saveDataSnapshot:NO ignorePagination:YES transformerKey:nil
                                    pages:nil attachmentsPrefix:nil parameters:parameters delegate:delegate];
}

#pragma mark - JMActionBarProvider

- (id)actionBar
{
    if (!self.actionBarView) {
        self.actionBarView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([JMDetailReportViewerActionBarView class])
                                                           owner:self
                                                         options:nil].firstObject;
        if (!self.inputControls || [self.inputControls count] == 0) {
            self.actionBarView.disabledAction = JMBaseActionBarViewAction_Edit;
        }
        self.actionBarView.delegate = self;
        self.actionBarView.titleLabel.text = self.resourceLookup.label;
    }
    
    return self.actionBarView;
}

#pragma mark - JMBaseActionBarViewDelegate
- (void)actionView:(JMBaseActionBarView *)actionView didSelectAction:(JMBaseActionBarViewAction)action{
    switch (action) {
        case JMBaseActionBarViewAction_Refresh:
            [self runReportExecution];
            break;
        case JMBaseActionBarViewAction_Share:
            break;
        case JMBaseActionBarViewAction_Edit:
            [self edit];
            break;
        case JMBaseActionBarViewAction_Delete:
            break;
        default:
            // Unsupported actions
            break;
    }
}

- (void) edit{
    [self performSegueWithIdentifier:kJMShowReportOptionsSegue sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    [destinationViewController setInputControls:[self.inputControls mutableCopy]];
    [destinationViewController setResourceLookup:self.resourceLookup];
    [destinationViewController setDelegate:self];
}

#pragma mark - JMFullScreenButtonProvider
- (BOOL)shouldDisplayFullScreenButton
{
    return YES;
}


#pragma mark - JMRefreshable

- (void)refresh
{
    [self.navigationController popToViewController:self animated:YES];
    [self runReportExecution];
}

#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
