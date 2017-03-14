/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Olexandr Dahno odahno@tibco.com
 @since 2.6
 */

@import UIKit;

extern NSString *const JMResourceContentViewDidMoveToSuperViewNotification;
extern NSString *const JMResourceContentViewDidLayoutSubviewsNotification;

@interface JMResourceContentView : UIView
@end

@interface JMBaseResourceView : UIView
@property(nonatomic, weak) IBOutlet UIView *topView;
@property(nonatomic, weak) IBOutlet UIView *container;
@property(nonatomic, weak) IBOutlet JMResourceContentView *contentView;
@property(nonatomic, weak) IBOutlet UIView *bottomView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottomConstraint;
@end
