//
//  JSUIResourceModifyViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 21.08.12.
//  Copyright (c) 2012 Jaspersoft. All rights reserved.
//

#import "JSUIResourceModifyViewController.h"

@interface JSUIResourceModifyViewController ()

@end

@implementation JSUIResourceModifyViewController

@synthesize resourceClient;
@synthesize descriptor;
@synthesize resourceLabelTextField;
@synthesize resourceDescriptionTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.descriptor.label;
    self.resourceLabelTextField.text = self.descriptor.label;
    self.resourceDescriptionTextView.text = self.descriptor.resourceDescription;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self 
                                                                              action:@selector(doneClicked:)];
}

- (void)viewDidUnload {
    [self setResourceLabelTextField:nil];
    [self setResourceDescriptionTextView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)slideTextViewUp:(BOOL)b {
    [UIView beginAnimations:@"slide" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: 0.3f];
    self.view.frame = CGRectOffset(self.view.frame,0, 87 * ((b) ? -1 : 1));
    [UIView commitAnimations];
    
}

- (BOOL)textViewShouldReturn:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.resourceDescriptionTextView) {
        [self slideTextViewUp: YES];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView == self.resourceDescriptionTextView) {
        [self slideTextViewUp: NO];
    }
}


- (IBAction)doneClicked:(UIButton *)sender {
    
    // Create new label and description from text fields
    NSString *newLabel = [[self.resourceLabelTextField text] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *newDescription = [[self.resourceDescriptionTextView text] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.descriptor setLabel: newLabel];
    [self.descriptor setResourceDescription: newDescription];
    
    // Send request for modifying resource desctiptor
    [self.resourceClient modifyResource:self.descriptor delegate:self];
    
    // Hide keyboard
    [self.resourceLabelTextField resignFirstResponder];
    [self.resourceDescriptionTextView resignFirstResponder];
}

- (void)requestFinished:(JSOperationResult *)op {
    NSMutableString *msg = [NSMutableString string];
    NSString *title = @"";
    
    if (op != nil) {        
        if (op.statusCode >= 400 || op.error != nil) {
            title = @"Error reading the response";            
            if (op.error) {
                [msg appendFormat:@"%@\n", [op.error localizedDescription]]; 
            }     
        }
    } else {
        msg = [NSMutableString stringWithString:@"Error reading the response"];
    }
    
    if (msg.length || title.length) {
        UIAlertView *uiView =[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Cancel", nil];
        [uiView show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
