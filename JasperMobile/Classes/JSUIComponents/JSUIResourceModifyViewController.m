//
//  JSUIResourceModifyViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 21.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSUIResourceModifyViewController.h"

@interface JSUIResourceModifyViewController ()

@property (nonatomic, retain) UIBarButtonItem *resourceDescriptionDoneButton;

@end

@implementation JSUIResourceModifyViewController

@synthesize client;
@synthesize descriptor;
@synthesize resourceLabelTextField;
@synthesize resourceDescriptionTextView;
@synthesize resourceDescriptionDoneButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.descriptor.label;
    self.resourceLabelTextField.text = self.descriptor.label;
    self.resourceDescriptionTextView.text = self.descriptor.description;
    self.resourceDescriptionDoneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style: UIBarButtonItemStyleDone target: nil action: @selector(doneButtonClicked:)];    
}

- (void)viewDidUnload
{
    [self setResourceLabelTextField:nil];
    [self setResourceDescriptionTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    
}

-(void)slideTextViewUp:(BOOL)b
{
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
        self.navigationItem.rightBarButtonItem = self.resourceDescriptionDoneButton;
        [self slideTextViewUp: YES];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView == self.resourceDescriptionTextView) {
        [self slideTextViewUp: NO];
    }
}

- (void)doneButtonClicked:(id)sender {
    self.navigationItem.rightBarButtonItem = nil;
    [self.resourceDescriptionTextView resignFirstResponder];
}

- (void)dealloc {
    [resourceLabelTextField release];
    [resourceDescriptionTextView release];
    [client release];
    [descriptor release];
    [resourceDescriptionDoneButton release];
    [super dealloc];
}

- (IBAction)saveResourceClicked:(UIButton *)sender {
    
    // Create new label and description from text fields
    NSString *newLabel = [[self.resourceLabelTextField text] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *newDescription = [[self.resourceDescriptionTextView text] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.descriptor setLabel: newLabel];
    [self.descriptor setDescription: newDescription];
    
    // Send request for modifying resource desctiptor
    [self.client resourceModify:self.descriptor.uri resourceDescriptor:self.descriptor data: nil responseDelegate:self];
    
    // Clear top bar from "Done" button. Also hide keyboard
    self.navigationItem.rightBarButtonItem = nil;
    [self.resourceLabelTextField resignFirstResponder];
    [self.resourceDescriptionTextView resignFirstResponder];
}

- (void)requestFinished:(JSOperationResult *)op
{
    NSString *msg = nil;
    
    if (op != nil) {
        msg = [NSString stringWithFormat:@"Return code: %d\n%@", [op returnCode], [op message]];
        
        if ([op returnCode] == 200) {
            msg = @"Resource was successfully modified";
        }
        NSLog(@"%@", self.navigationController);
    } else {
        msg = @"Operation failed...";
    }
    UIAlertView *uiView =[[[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Back", nil] autorelease];
    [uiView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
