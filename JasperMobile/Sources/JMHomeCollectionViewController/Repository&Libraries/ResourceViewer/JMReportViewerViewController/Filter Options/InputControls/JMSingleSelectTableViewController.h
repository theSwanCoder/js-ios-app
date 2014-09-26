//
//  JMSingleSelectTableViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/16/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMSingleSelectInputControlCell.h"

@interface JMSingleSelectTableViewController : UIViewController
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) JMSingleSelectInputControlCell *cell;
@property (nonatomic, readonly) NSArray *listOfValues;

@property (nonatomic, strong) NSMutableSet *selectedValues;

@end