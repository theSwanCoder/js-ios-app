//
//  JMServerOptionsViewController.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMServerProfile.h"

@protocol JMServerOptionsViewControllerDelegate <NSObject>

@required
- (void) serverOptionsDidChanged;

@end

@interface JMServerOptionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) JMServerProfile *serverProfile;
@property (nonatomic, weak) id <JMServerOptionsViewControllerDelegate> delegate;
@end
