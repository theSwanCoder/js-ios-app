/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


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
        CGSize neededContentSize = [self.tableView sizeThatFits:CGSizeMake(self.tableView.frame.size.width, MAXFLOAT)];

        if (contentSize.height <= neededContentSize.height) {
            contentSize.height += keyboardHeight;
            self.tableView.contentSize = contentSize;
        }
    }
}

- (void)keyboarDidHide:(NSNotification*)aNotification
{
    [UIView beginAnimations:nil context:nil];
    self.tableView.contentSize = [self.tableView sizeThatFits:CGSizeMake(self.tableView.frame.size.width, MAXFLOAT)];
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
    CGSize keyboardSize = [userInfo[key] CGRectValue].size;
    return MIN(keyboardSize.height, keyboardSize.width);    // Fixing bug on iOS 7
}

- (UITableView *) tableView
{
    @throw [NSException exceptionWithName:@"Method implementation is missing" reason:[NSString stringWithFormat:@"You need to implement \"%@\" method in \"%@\" class", NSStringFromSelector(_cmd), NSStringFromClass(self.class)] userInfo:nil];
}
@end
