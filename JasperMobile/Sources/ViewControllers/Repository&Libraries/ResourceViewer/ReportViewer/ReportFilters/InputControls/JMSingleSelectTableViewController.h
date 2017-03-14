/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

@import UIKit;
#import "JMBaseViewController.h"

@class JMSingleSelectInputControlCell;

@interface JMSingleSelectTableViewController : JMBaseViewController
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) JMSingleSelectInputControlCell *cell;
@property (nonatomic, readonly) NSArray *listOfValues;

@property (nonatomic, readonly) NSArray *selectedValues;

- (void) applyFiltering;

- (NSPredicate *)selectedValuesPredicate;

- (NSPredicate *)filteredPredicateWithText:(NSString *)text;

@end
