//
//  JMServerSettingsTableViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/25/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMServerProfile+Helpers.h"

@protocol JMServerSettingsTableViewControllerDelegate;

@interface JMServerSettingsTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) JMServerProfile *serverToEdit;
@property (nonatomic, strong) NSArray *servers;
@property (nonatomic, weak) id <JMServerSettingsTableViewControllerDelegate> delegate;

@end

@protocol JMServerSettingsTableViewControllerDelegate
@required
- (void)updateWithServerProfile:(JMServerProfile *)serverProfile;

@end
