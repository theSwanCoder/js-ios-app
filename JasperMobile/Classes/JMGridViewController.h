//
//  JMGridViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 4/30/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMRefreshable.h"
#import "JMDetailViewController.h"

// TODO: create base CollectionViewController to avoid code duplications (if still will be needed)
@interface JMGridViewController : UICollectionViewController <JMRefreshable>

@property (nonatomic, weak) JMDetailViewController *delegate;

@end
