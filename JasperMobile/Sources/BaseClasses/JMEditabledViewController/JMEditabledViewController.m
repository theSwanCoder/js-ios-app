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
        id cell = activeView;
        while (![cell isKindOfClass:[UITableViewCell class]]) {
            cell = [cell superview];
        }

        CGRect activeTableViewRect = [cell convertRect:activeView.frame fromView:[cell contentView]];
        activeTableViewRect = [self.tableView convertRect:activeTableViewRect fromView:cell];
        
        CGRect activeViewRect = [self.view convertRect:activeTableViewRect fromView:self.tableView];
        
        CGFloat keyboardHeight = [self getKeyboardHeightFromUserInfo:[aNotification userInfo] key:UIKeyboardFrameEndUserInfoKey];
        CGFloat visibleAreaHeight = self.view.frame.size.height - keyboardHeight;
        if ((activeViewRect.origin.y + activeViewRect.size.height) > visibleAreaHeight) {
            CGFloat offset = activeTableViewRect.origin.y - (visibleAreaHeight - self.tableView.frame.origin.y - activeTableViewRect.size.height);
            [self.tableView setContentOffset:CGPointMake(0, offset) animated:YES];
        }
        CGSize contentSize = self.tableView.contentSize;
        contentSize.height += keyboardHeight;
        self.tableView.contentSize = contentSize;
    }
}

- (void)keyboarDidHide:(NSNotification*)aNotification
{
    CGSize contentSize = self.tableView.contentSize;
    contentSize.height -= [self getKeyboardHeightFromUserInfo:[aNotification userInfo] key:UIKeyboardFrameBeginUserInfoKey];

    [UIView beginAnimations:nil context:nil];
    self.tableView.contentSize = contentSize;
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

- (UITableView *) tableView
{
    @throw [NSException exceptionWithName:@"Method implementation is missing" reason:@"You need to implement \"tableView\" method in subclasses" userInfo:nil];
}
@end
