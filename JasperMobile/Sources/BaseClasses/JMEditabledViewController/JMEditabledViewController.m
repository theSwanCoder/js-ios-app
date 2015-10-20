/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
