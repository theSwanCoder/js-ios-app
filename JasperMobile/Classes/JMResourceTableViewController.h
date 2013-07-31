//
//  JMResourceTableViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/7/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMResourceClientHolder.h"
#import "JMResourceModifyViewController.h"
#import <UIKit/UIKit.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>

@protocol JMResourceTableViewControllerDelegate;

@interface JMResourceTableViewController : UITableViewController <JMResourceClientHolder, JSRequestDelegate, JMResourceModifyViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id <JMResourceTableViewControllerDelegate> delegate;

@end

@protocol JMResourceTableViewControllerDelegate <NSObject>
@required
- (void)removeResource;
- (void)refreshWithResource:(JSResourceDescriptor *)resourceDescriptor;

@end

