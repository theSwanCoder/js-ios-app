//
//  JMResourceModifyViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/13/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMResourceModifyViewController.h"
#import "JMFilter.h"
#import "JMViewControllerHelper.h"
#import <QuartzCore/QuartzCore.h>
#import <Objection-iOS/Objection.h>

@interface JMResourceModifyViewController ()
@property (nonatomic, weak) IBOutlet UITextField *labelTextField;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

- (void)showDoneButton;
- (void)hideDoneButton;
@end

@implementation JMResourceModifyViewController
objection_requires(@"resourceClient");

#pragma mark - Accessors

@synthesize resourceClient = _resourceClient;
@synthesize resourceDescriptor = _resourceDescriptor;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [JMViewControllerHelper awakeFromNibForResourceViewController:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.labelTextField.text = self.resourceDescriptor.label;
    self.labelTextField.delegate = self;
    
    self.descriptionTextView.text = self.resourceDescriptor.resourceDescription;
    self.descriptionTextView.layer.cornerRadius = 5.0f;
//    self.descriptionTextView.delegate = self;
    
    [self hideDoneButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidUnload {
    [self setLabelTextField:nil];
    [self setDescriptionTextView:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
}

#pragma mark - Actions

- (IBAction)doneEditing:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)modifyResource:(id)sender {
    NSString *updatedLabel = [self.labelTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *updatedDescription = [[self.descriptionTextView text] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    self.resourceDescriptor.label = updatedLabel;
    self.resourceDescriptor.resourceDescription = updatedDescription;
    
    [self.view endEditing:YES];
    
    [JMFilter checkNetworkReachabilityForBlock:^{
        [self.resourceClient modifyResource:self.resourceDescriptor delegate:[JMFilter checkRequestResultForDelegate:self]];
    } viewControllerToDismiss:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.descriptionTextView becomeFirstResponder];
    return YES;
}

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    [self.delegate setNeedsToRefreshResourceDescriptorData:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Notifications

- (void)keyboardWillHide:(NSNotification*)notification
{
    [self hideDoneButton];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    [self showDoneButton];
}

#pragma mark - Private

- (void)hideDoneButton
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)showDoneButton
{
    self.navigationItem.rightBarButtonItem = self.doneButton;
}

@end
