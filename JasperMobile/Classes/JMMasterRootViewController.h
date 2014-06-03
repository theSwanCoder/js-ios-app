//
//  JMMasterRootViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/29/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMHomeCollectionViewController.h"

@interface JMMasterRootViewController : UIViewController

@property (nonatomic, weak) id <JMHomeCollectionViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIView *logoView;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

- (void)instantiateSubMasterViewControllerWithIdentifier:(NSString *)identifier;
- (void)removeSubMasterViewController;

@end
