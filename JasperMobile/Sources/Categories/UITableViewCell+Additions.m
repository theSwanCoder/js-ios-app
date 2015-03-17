/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
//  UITableViewCell+Additions.h
//  TIBCO JasperMobile
//

#import "UITableViewCell+Additions.h"
#import "JMUtils.h"

NSInteger static kJMTopSeparatorTagIndex = 10;
NSInteger static kJMBottomSeparatorTagIndex = 11;

@implementation UITableViewCell (Additions)

- (void)setTopSeparatorWithHeight:(CGFloat)height color:(UIColor *)color tableViewStyle:(UITableViewStyle)style
{
    if (![self isSeparatorNeeded:style]) return;
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, height)];
    separator.backgroundColor = color;
    separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    // TODO: we need oportunity to remove this separator
    separator.tag = kJMTopSeparatorTagIndex;
    [self addSubview:separator];
}

- (void)removeTopSeparator
{
    NSArray *subviews = self.subviews;
    for (UIView *subview in subviews) {
        if (subview.tag == kJMTopSeparatorTagIndex) {
            [subview removeFromSuperview];
        }
    }
}

- (void)setBottomSeparatorWithHeight:(CGFloat)height color:(UIColor *)color tableViewStyle:(UITableViewStyle)style
{
    if (![self isSeparatorNeeded:style]) return;
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - height, self.frame.size.width, height)];
    separator.backgroundColor = color;
    separator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    // TODO: we need oportunity to remove this separator
    separator.tag = kJMBottomSeparatorTagIndex;
    [self addSubview:separator];
}

- (void)removeBottomSeparator
{
    NSArray *subviews = self.subviews;
    for (UIView *subview in subviews) {
        if (subview.tag == kJMBottomSeparatorTagIndex) {
            [subview removeFromSuperview];
        }
    }
}

#pragma mark - Private

- (BOOL)isSeparatorNeeded:(UITableViewStyle)style
{
    return style != UITableViewStyleGrouped;
}

- (UIToolbar *)toolbarForInputAccessoryView
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [toolbar setItems:[self inputAccessoryViewToolbarItems]];
    [toolbar sizeToFit];
    if ([JMUtils isIphone]) {
        CGRect toolBarRect = toolbar.frame;
        toolBarRect.size.height = 34;
        toolbar.frame = toolBarRect;
    }
    return toolbar;
}

- (NSArray *)inputAccessoryViewToolbarItems
{
    NSMutableArray *items = [NSMutableArray arrayWithArray:[self leftInputAccessoryViewToolbarItems]];
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    [items addObjectsFromArray:[self rightInputAccessoryViewToolbarItems]];
    return items;
}

- (NSArray *)leftInputAccessoryViewToolbarItems
{
    return [NSArray array];
}

- (NSArray *)rightInputAccessoryViewToolbarItems
{
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    return @[done];
}

- (void)doneButtonTapped:(id)sender
{
    
}
@end
