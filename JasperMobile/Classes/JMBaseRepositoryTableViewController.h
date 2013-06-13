//
//  JMRepositoryTableViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/27/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JaspersoftSDK.h"
#import "JMResourceClientHolder.h"

@interface JMBaseRepositoryTableViewController : UITableViewController <JMResourceClientHolder, JSRequestDelegate>

@property (nonatomic, strong) JSConstants *constants;

/**
 Removes specified resource descriptor from table view
 
 @param resourceDescriptor A resource to remove from table view
 */
- (void)removeResource:(JSResourceDescriptor *)resourceDescriptor;

@end
