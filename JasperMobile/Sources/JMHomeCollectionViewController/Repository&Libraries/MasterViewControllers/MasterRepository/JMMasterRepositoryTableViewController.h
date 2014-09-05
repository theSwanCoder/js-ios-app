//
//  JMMasterRepositoryTableViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/13/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMMasterResourceViewController.h"
#import "JMPagination.h"

@interface JMMasterRepositoryTableViewController : JMMasterResourceViewController <JMResourceClientHolder, JMPagination>

@property (nonatomic, weak) JMMasterRepositoryTableViewController *delegate;

@end
