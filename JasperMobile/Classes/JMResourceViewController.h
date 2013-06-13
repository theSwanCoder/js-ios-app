//
//  JMResourceViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/7/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JaspersoftSDK.h"
#import "JMResourceClientHolder.h"

@interface JMResourceViewController : UITableViewController <JMResourceClientHolder, JSRequestDelegate, UIAlertViewDelegate>

@end
