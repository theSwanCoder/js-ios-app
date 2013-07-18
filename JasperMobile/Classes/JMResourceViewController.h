//
//  JMResourceViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/7/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>
#import "JMResourceClientHolder.h"
#import "JMResourceModifyViewController.h"

@protocol JMResourceViewControllerDelegate;

@interface JMResourceViewController : UITableViewController <JMResourceClientHolder, JSRequestDelegate, JMResourceModifyViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id <JMResourceViewControllerDelegate> delegate;

@end

@protocol JMResourceViewControllerDelegate <NSObject>
@required
- (void)removeResource;
- (void)refreshWithResource:(JSResourceDescriptor *)resourceDescriptor;

@end

