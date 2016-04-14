//
//  JMShareSettingsViewController.h
//  TIBCO JasperMobile
//
//  Created by Oleksii Gubariev on 4/1/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

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
