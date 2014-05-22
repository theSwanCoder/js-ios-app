//
//  JMBackButtonView.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/22/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMBackHeaderView : UIView

@property (nonatomic, weak) IBOutlet UILabel *label;

- (void)setOnTapGestureCallback:(void (^)(UITapGestureRecognizer *))callback;

@end
