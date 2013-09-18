/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */

//
//  JMResourceModifyViewController.m
//  Jaspersoft Corporation
//

#import "JMResourceModifyViewController.h"
#import "JMLocalization.h"
#import "JMUtils.h"
#import "JMRequestDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <Objection-iOS/Objection.h>

@implementation JMResourceModifyViewController
objection_requires(@"resourceClient")

#pragma mark - Accessors

@synthesize resourceClient = _resourceClient;
@synthesize resourceDescriptor = _resourceDescriptor;

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
    [JMUtils setTitleForResourceViewController:self];
    
    self.labelTextField.text = self.resourceDescriptor.label;
    self.labelTextField.delegate = self;
    
    self.descriptionTextView.text = self.resourceDescriptor.resourceDescription;
    self.descriptionTextView.layer.cornerRadius = 5.0f;
    
    self.label.text = JMCustomLocalizedString(@"resource.label.title", nil);
    self.descriptionLabel.text = JMCustomLocalizedString(@"resource.description.title", nil);
}

- (void)viewDidUnload
{
    [self setLabelTextField:nil];
    [self setDescriptionTextView:nil];
    [self setLabel:nil];
    [self setDescriptionLabel:nil];
    [self setDelegate:nil];
    [self setResourceClient:nil];
    [self setResourceDescriptor:nil];
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
    [self.resourceClient modifyResource:self.resourceDescriptor delegate:[JMRequestDelegate checkRequestResultForDelegate:self]];
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
