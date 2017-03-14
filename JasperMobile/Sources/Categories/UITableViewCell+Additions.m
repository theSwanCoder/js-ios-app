/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "UITableViewCell+Additions.h"
#import "JMUtils.h"

@implementation UITableViewCell (Additions)

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
    if (([JMUtils isCompactWidth] || [JMUtils isCompactHeight])) {
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
