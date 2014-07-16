//
//  JMDetailSingleSelectTableViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/16/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMSingleSelectInputControlCell.h"

@interface JMDetailSingleSelectTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *leftArrowImageView;
@property (nonatomic, weak) IBOutlet UILabel *backLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@property (nonatomic, weak) IBOutlet UITextField *searchTextField;
@property (nonatomic, weak) IBOutlet UILabel *searchLabel;
@property (nonatomic, weak) JMSingleSelectInputControlCell *cell;
@property (nonatomic, strong) NSMutableSet *selectedValues;

@end
