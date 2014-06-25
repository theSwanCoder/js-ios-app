//
//  JMCustomSplitViewController.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/18/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMCustomSplitViewController : UIViewController <UINavigationControllerDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIView *masterView;
@property (nonatomic, weak) IBOutlet UIView *detailView;
@property (nonatomic, weak) IBOutlet UILabel *menuLabel;
@property (nonatomic, weak) IBOutlet UILabel *headerBarLabel;
@property (nonatomic, weak) IBOutlet UIView *logoView;
@property (nonatomic, weak) IBOutlet UITextField *searchTextField;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;

// Provided by child view controllers
@property (weak, nonatomic) IBOutlet UIView *actionBarPlaceholderView;

@end
