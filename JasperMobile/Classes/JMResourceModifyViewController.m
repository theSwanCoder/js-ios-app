//
//  JMResourceModifyViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/13/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMResourceModifyViewController.h"
#import "JMFilter.h"
#import "JMLocalization.h"
#import "JMUtils.h"
#import <QuartzCore/QuartzCore.h>
#import <Objection-iOS/Objection.h>

@interface JMResourceModifyViewController ()
@property (nonatomic, weak) IBOutlet UITextField *labelTextField;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UILabel *description;
@end

@implementation JMResourceModifyViewController
objection_requires(@"resourceClient");

#pragma mark - Accessors

@synthesize resourceClient = _resourceClient;
@synthesize resourceDescriptor = _resourceDescriptor;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [JMUtils setTitleForResourceViewController:self];
    
    self.labelTextField.text = self.resourceDescriptor.label;
    self.labelTextField.delegate = self;
    
    self.descriptionTextView.text = self.resourceDescriptor.resourceDescription;
    self.descriptionTextView.layer.cornerRadius = 5.0f;
    
    self.label.text = JMCustomLocalizedString(@"resource.label.title", nil);
    self.description.text = JMCustomLocalizedString(@"resource.description.title", nil);
}

- (void)viewDidUnload
{
    [self setLabelTextField:nil];
    [self setDescriptionTextView:nil];
    [self setLabel:nil];
    [self setDescription:nil];
    [super viewDidUnload];
}

#pragma mark - Actions

- (IBAction)modifyResource:(id)sender
{
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
    [self.labelTextField resignFirstResponder];
    // Using perform selector instead of calling becomeFirstResponder directly fixes
    // issue with new line at the beginning in description text view
    // (more details about issue: http://stackoverflow.com/questions/1896399/becomefirstresponder-on-uitextview-not-working )
    [self.descriptionTextView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
    return YES;
}

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    [self.delegate setNeedsToRefreshResourceDescriptorData:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
