//
//  JMBaseResourcesViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/4/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMPagination.h"
#import "JMResourceClientHolder.h"
#import "JMActionBarProvider.h"
#import "JMRefreshable.h"

extern NSString * kJMResourceCellIdentifier;
extern NSString * kJMLoadingCellIdentifier;

@interface JMBaseResourcesViewController : UIViewController <JMRefreshable, JMActionBarProvider>

@property (nonatomic, weak) UIViewController <JMPagination, JMResourceClientHolder, JMActionBarProvider> *delegate;
@property (nonatomic, weak) JSConstants *constants;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfResourcesInSection:(NSInteger)section;
- (void)didSelectResourceAtIndexPath:(NSIndexPath *)indexPath;

@end
