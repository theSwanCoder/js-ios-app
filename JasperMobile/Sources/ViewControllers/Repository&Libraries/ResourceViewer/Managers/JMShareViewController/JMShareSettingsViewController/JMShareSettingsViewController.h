/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.5
 */

#import "JMBaseViewController.h"

@class JMShareSettingsViewController;
@protocol JMShareSettingsViewControllerDelegate <NSObject>
- (void) settingsDidChangedOnController:(JMShareSettingsViewController *)settingsController;

@end

@interface JMShareSettingsViewController : JMBaseViewController

@property (nonatomic, strong) UIColor *drawingColor;
@property (nonatomic, assign) CGFloat brushWidth;
@property (nonatomic, assign) CGFloat opacity;
@property (nonatomic, assign) BOOL borders;

@property (nonatomic, strong) UIFont *selectedFont;

@property (nonatomic, weak) id <JMShareSettingsViewControllerDelegate> delegate;

@end
