//
//  JMEditabledViewController.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/29/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMEditabledViewController.h"

@implementation JMEditabledViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboarDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - Layout subviews with using keyboard
// Called when the UIKeyboardWillShowNotification is sent.
- (void)keyboardWillShown:(NSNotification*)aNotification
{
    UIView *activeView = [self getFirstResponderForView:self.view];
    if (activeView) {
        NSDictionary* info = [aNotification userInfo];
        
        CGFloat statusBarHeight = 0;
        CGFloat keyboardOffset = 0;
        CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;

        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        } else {
            statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.width;
        }
        keyboardOffset = [self getKeyboardHeightFromUserInfo:info key:UIKeyboardFrameEndUserInfoKey] - statusBarHeight - navBarHeight;
        
        CGRect activeViewRect = [activeView convertRect:activeView.frame toView:self.scrollView];
        if ((activeViewRect.origin.y + activeViewRect.size.height + 20 - self.scrollView.contentOffset.y + self.scrollView.frame.origin.y) > keyboardOffset) {
            CGFloat offset = activeViewRect.origin.y + activeViewRect.size.height + 20 - keyboardOffset + self.scrollView.frame.origin.y;
            [self.scrollView setContentOffset:CGPointMake(0, offset) animated:YES];
        }
        
        CGSize contentSize = self.scrollView.contentSize;
        contentSize.height += [self getKeyboardHeightFromUserInfo:info key:UIKeyboardFrameEndUserInfoKey];
        self.scrollView.contentSize = contentSize;
        self.scrollView.scrollEnabled = YES;
    }
}

- (void)keyboarDidHide:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height -= [self getKeyboardHeightFromUserInfo:info key:UIKeyboardFrameBeginUserInfoKey];

    [UIView beginAnimations:nil context:nil];
    self.scrollView.contentSize = contentSize;
    [UIView commitAnimations];
}

- (UIView *) getFirstResponderForView:(UIView *)view
{
    if (view.isFirstResponder) {
        return view;
    }
    
    for (UIView *subView in view.subviews) {
        UIView *firstResponder = [self getFirstResponderForView:subView];
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    return nil;
}

- (CGFloat) getKeyboardHeightFromUserInfo:(NSDictionary *)userInfo key:(NSString *)key
{
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        return [[userInfo objectForKey:key] CGRectValue].size.height;
    } else {
        return [[userInfo objectForKey:key] CGRectValue].size.width;
    }
}
@end
