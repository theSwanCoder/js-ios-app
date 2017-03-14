/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.6
 */

#import <UIKit/UIKit.h>

/**
 Provides methods for setting top and bottom separators for table view cell
 */
@interface UITableViewCell (Additions)

- (UIToolbar *)toolbarForInputAccessoryView;

- (NSArray *)inputAccessoryViewToolbarItems;

- (NSArray *)rightInputAccessoryViewToolbarItems;

- (NSArray *)leftInputAccessoryViewToolbarItems;

- (void)doneButtonTapped:(id)sender;
@end
